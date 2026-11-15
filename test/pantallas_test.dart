import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:huellitas_veterinaria/admin_citas.dart';
import 'package:huellitas_veterinaria/citas.dart';
import 'package:huellitas_veterinaria/huellitas_theme.dart';
import 'package:huellitas_veterinaria/mascota_model.dart';
import 'package:huellitas_veterinaria/pedidos.dart';
import 'package:huellitas_veterinaria/repositories/carrito_repository.dart';
import 'package:huellitas_veterinaria/repositories/cita_repository.dart';
import 'package:huellitas_veterinaria/repositories/db.dart';
import 'package:huellitas_veterinaria/repositories/usuario_repository.dart';
import 'package:huellitas_veterinaria/tienda.dart';
import 'package:huellitas_veterinaria/veterinario_tareas.dart';

void main() {
  late FakeFirebaseFirestore db;

  final luna = MascotaModel(id: 'm1', nombre: 'Luna', tipo: 'Gato', raza: 'Criollo');
  UsuarioModel ana({bool conMascota = true}) => UsuarioModel(
        uid: 'ana', nombre: 'Ana', apellido: 'Paz', correo: 'ana@x.co',
        mascotas: conMascota ? [luna] : [],
      );
  final vet1 = UsuarioModel(uid: 'vet1', nombre: 'Laura', apellido: 'Ríos', rol: 'veterinario', especialidad: 'Felinos');

  // Una fecha futura fija, para no depender de la hora en que corre la prueba.
  final manana = DateTime.now().add(const Duration(days: 1));
  final fecha = manana.toIso8601String().substring(0, 10);

  CitaModel cita({String? vet}) => CitaModel(
        mascota: 'Luna', mascotaId: 'm1', servicio: 'Vacunación',
        fecha: fecha, hora: '09:00',
        veterinarioId: vet, veterinarioNombre: vet == null ? null : 'Laura Ríos',
      );

  setUp(() async {
    db = FakeFirebaseFirestore();
    Db.usar(db);
    await UsuarioRepository.crear('ana', ana());
    await UsuarioRepository.crear('vet1', vet1);
  });
  tearDown(() => Db.usar(null));

  Future<void> abrir(WidgetTester tester, Widget pagina) async {
    tester.view.physicalSize = const Size(420, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(theme: HuellitasTheme.theme, home: Scaffold(body: pagina)));
    await tester.pumpAndSettle();
  }

  group('cliente: citas', () {
    testWidgets('sin mascotas, el formulario explica qué falta en vez de guardar una cita vacía', (tester) async {
      await abrir(tester, CitasPage(usuario: ana(conMascota: false)));
      await tester.tap(find.text('Agendar'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Primero registra a tu mascota'), findsOneWidget);
      expect(find.text('Reservar cita'), findsNothing);
    });

    testWidgets('no reserva sin fecha ni hora y lo dice en el formulario', (tester) async {
      await abrir(tester, CitasPage(usuario: ana()));
      await tester.tap(find.text('Agendar'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Reservar cita'));
      await tester.tap(find.text('Reservar cita'));
      await tester.pumpAndSettle();

      expect(find.text('Selecciona una fecha'), findsOneWidget);
      expect((await db.collection('usuarios/ana/citas').get()).docs, isEmpty);
    });

    testWidgets('cancelar pasa la cita al historial y libera el horario', (tester) async {
      await CitaRepository.agendar('ana', cita(vet: 'vet1'));
      await abrir(tester, CitasPage(usuario: ana()));

      expect(find.text('Laura Ríos'), findsOneWidget);
      expect(find.text('Pendiente'), findsOneWidget);

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar cita').last);
      await tester.pumpAndSettle();

      expect(find.text('Cancelada'), findsOneWidget);
      expect(find.text('Cancelar'), findsNothing);
      expect(await CitaRepository.horasOcupadas('vet1', fecha), isEmpty);
    });

    testWidgets('una cita sin veterinario lo indica', (tester) async {
      await CitaRepository.agendar('ana', cita());
      await abrir(tester, CitasPage(usuario: ana()));
      expect(find.text('Veterinario por asignar'), findsOneWidget);
    });
  });

  group('admin: citas', () {
    testWidgets('asigna veterinario a una cita que no lo tiene', (tester) async {
      await CitaRepository.agendar('ana', cita());
      await abrir(tester, const AdminCitasPage());

      expect(find.text('1 cita espera que le asignes veterinario.'), findsOneWidget);
      expect(find.text('Luna · Ana Paz'), findsOneWidget);

      await tester.tap(find.text('Asignar veterinario'));
      await tester.pumpAndSettle();
      expect(find.text('Felinos · Disponible'), findsOneWidget);
      await tester.tap(find.text('Laura Ríos'));
      await tester.pumpAndSettle();

      // (El simulador no reemite las consultas de grupo; se reabre la pantalla.)
      await abrir(tester, const SizedBox());
      await abrir(tester, const AdminCitasPage());
      expect(find.text('Todas las citas próximas tienen veterinario.'), findsOneWidget);
      final c = (await CitaRepository.stream('ana').first).single;
      expect(c.veterinarioId, 'vet1');
      expect(await CitaRepository.horasOcupadas('vet1', fecha), {'09:00'});
    });

    testWidgets('marca como ocupado al veterinario que ya tiene ese horario', (tester) async {
      await UsuarioRepository.crear('beto', UsuarioModel(uid: 'beto', nombre: 'Beto', mascotas: [luna]));
      await CitaRepository.agendar('beto', cita(vet: 'vet1'));
      await CitaRepository.agendar('ana', cita());
      await abrir(tester, const AdminCitasPage());

      await tester.tap(find.text('Asignar veterinario'));
      await tester.pumpAndSettle();
      expect(find.text('Ocupado a esa hora'), findsOneWidget);
    });
  });

  group('veterinario', () {
    testWidgets('ve su cita con dueño y mascota, y la marca atendida con notas', (tester) async {
      await CitaRepository.agendar('ana', cita(vet: 'vet1'));
      // La consulta de grupo del simulador necesita un ciclo para ver el documento.
      await abrir(tester, VeterinarioTareasPage(veterinario: vet1));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));

      expect(find.text('Ana Paz'), findsOneWidget);
      await tester.tap(find.text('Vacunación'));
      await tester.pumpAndSettle();
      expect(find.text('Registrar vacuna'), findsOneWidget);

      await tester.ensureVisible(find.text('Marcar atendida'));
      await tester.tap(find.text('Marcar atendida'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Vacuna aplicada');
      await tester.tap(find.text('Marcar atendida').last);
      await tester.pumpAndSettle();

      final c = (await CitaRepository.stream('ana').first).single;
      expect(c.estado, EstadoCita.atendida);
      expect(c.notas, 'Vacuna aplicada');
    });
  });

  group('tienda', () {
    Future<void> producto(String id, String nombre, {int stock = 5, double precio = 20000}) =>
        db.collection('productos').doc(id).set(
            ProductoModel(nombre: nombre, precio: precio, stock: stock).toFirestore());

    testWidgets('un producto agotado se marca y no se puede agregar', (tester) async {
      await producto('p1', 'Collar', stock: 0);
      await producto('p2', 'Pelota', stock: 2);
      await abrir(tester, TiendaPage(usuario: ana()));

      expect(find.text('Agotado'), findsOneWidget);
      expect(find.text('Quedan 2'), findsOneWidget);
      final botones = tester.widgetList<IconButton>(find.widgetWithIcon(IconButton, Icons.add_circle_outline_rounded)).toList();
      expect(botones[0].onPressed, isNull); // Collar (agotado)
      expect(botones[1].onPressed, isNotNull); // Pelota
    });

    testWidgets('comprar: se agrega hasta el stock, se confirma y queda el pedido', (tester) async {
      await producto('p1', 'Pelota', stock: 2, precio: 5000);
      await abrir(tester, TiendaPage(usuario: ana()));

      final mas = find.widgetWithIcon(IconButton, Icons.add_circle_outline_rounded);
      await tester.tap(mas);
      await tester.pumpAndSettle();
      await tester.tap(mas);
      await tester.pumpAndSettle();
      // Con las 2 unidades en el carrito ya no deja sumar otra.
      expect(tester.widget<IconButton>(mas).onPressed, isNull);

      await tester.tap(find.textContaining('Ver carrito'));
      await tester.pumpAndSettle();
      expect(find.text('Recoges y pagas tu pedido en la clínica.'), findsOneWidget);
      await tester.tap(find.text('Confirmar pedido'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Pedido confirmado'), findsOneWidget);
      final pedido = (await CarritoRepository.streamPedidos('ana').first).single;
      expect(pedido.total, 10000);
      expect(pedido.clienteNombre, 'Ana Paz');
      expect((await db.doc('productos/p1').get()).data()!['stock'], 0);
    });

    testWidgets('si un producto del carrito se agotó, lo avisa y no deja confirmar', (tester) async {
      await producto('p1', 'Pelota', stock: 2);
      await CarritoRepository.agregar('ana', ProductoModel(id: 'p1', nombre: 'Pelota', precio: 20000, stock: 2));
      await db.doc('productos/p1').update({'stock': 0});
      await abrir(tester, TiendaPage(usuario: ana()));

      await tester.tap(find.textContaining('Ver carrito'));
      await tester.pumpAndSettle();

      expect(find.text('Agotado'), findsWidgets);
      final confirmar = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Confirmar pedido'));
      expect(confirmar.onPressed, isNull);
      await tester.tap(find.text('Quitar'));
      await tester.pumpAndSettle();
      expect(find.text('El carrito está vacío'), findsOneWidget);
    });

    testWidgets('el cliente ve el estado de su pedido; el admin lo avanza', (tester) async {
      await producto('p1', 'Pelota', stock: 3, precio: 5000);
      await CarritoRepository.agregar('ana', ProductoModel(id: 'p1', nombre: 'Pelota', precio: 5000, stock: 3));
      await CarritoRepository.confirmarPedido('ana', await CarritoRepository.stream('ana').first, clienteNombre: 'Ana Paz');

      await abrir(tester, const PedidosPage());
      expect(find.text('Ana Paz'), findsOneWidget);
      expect(find.text('Pendiente'), findsOneWidget);
      await tester.tap(find.text('Marcar listo'));
      await tester.pumpAndSettle();
      await abrir(tester, const SizedBox());
      await abrir(tester, const PedidosPage());
      expect(find.text('Listo para recoger'), findsOneWidget);
      expect(find.text('Marcar entregado'), findsOneWidget);

      await abrir(tester, const SizedBox());
      await abrir(tester, const PedidosPage(uid: 'ana'));
      expect(find.text('Listo para recoger'), findsOneWidget);
      expect(find.textContaining('Ya puedes pasar a recogerlo'), findsOneWidget);
      expect(find.text('Marcar entregado'), findsNothing); // el cliente no cambia estados
    });
  });
}
