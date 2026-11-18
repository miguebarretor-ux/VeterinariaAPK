import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:huellitas_veterinaria/mascota_model.dart';
import 'package:huellitas_veterinaria/repositories/carrito_repository.dart';
import 'package:huellitas_veterinaria/repositories/cita_repository.dart';
import 'package:huellitas_veterinaria/repositories/db.dart';
import 'package:huellitas_veterinaria/repositories/usuario_repository.dart';

void main() {
  late FakeFirebaseFirestore db;

  setUp(() {
    db = FakeFirebaseFirestore();
    Db.usar(db);
  });
  tearDown(() => Db.usar(null));

  CitaModel cita({String? vet, String hora = '09:00'}) => CitaModel(
        mascota: 'Luna',
        mascotaId: 'm1',
        servicio: 'Vacunación',
        fecha: '2030-01-10',
        hora: hora,
        veterinarioId: vet,
        veterinarioNombre: vet == null ? null : 'Vet $vet',
      );

  final vet1 = UsuarioModel(uid: 'vet1', nombre: 'Vet', apellido: 'Uno', rol: 'veterinario');
  final vet2 = UsuarioModel(uid: 'vet2', nombre: 'Vet', apellido: 'Dos', rol: 'veterinario');

  group('citas', () {
    test('agendar con veterinario reserva su horario', () async {
      await CitaRepository.agendar('ana', cita(vet: 'vet1'));

      final citas = await CitaRepository.stream('ana').first;
      expect(citas.single.estado, EstadoCita.pendiente);
      expect(citas.single.duenoUid, 'ana');
      expect(citas.single.mascotaId, 'm1');
      expect(await CitaRepository.horasOcupadas('vet1', '2030-01-10'), {'09:00'});
      expect(await CitaRepository.horasOcupadas('vet1', '2030-01-11'), isEmpty);
      expect(await CitaRepository.horasOcupadas('vet2', '2030-01-10'), isEmpty);
    });

    test('dos personas no pueden agendar al mismo veterinario a la misma hora', () async {
      await CitaRepository.agendar('ana', cita(vet: 'vet1'));

      await expectLater(
        CitaRepository.agendar('beto', cita(vet: 'vet1')),
        throwsA(isA<OperacionException>()),
      );
      expect(await CitaRepository.stream('beto').first, isEmpty);

      // Otra hora u otro veterinario sí se puede.
      await CitaRepository.agendar('beto', cita(vet: 'vet1', hora: '10:00'));
      await CitaRepository.agendar('beto', cita(vet: 'vet2'));
    });

    test('sin preferencia no reserva horario y queda sin asignar', () async {
      await CitaRepository.agendar('ana', cita());
      await CitaRepository.agendar('beto', cita());

      final c = (await CitaRepository.stream('ana').first).single;
      expect(c.sinAsignar, isTrue);
      expect((await db.collection('agenda').get()).docs, isEmpty);
      // El campo existe aunque sea null, para poder encontrarla después.
      final crudo = (await db.collection('usuarios/ana/citas').get()).docs.single.data();
      expect(crudo.containsKey('veterinarioId'), isTrue);
    });

    test('cancelar conserva la cita en el historial y libera el horario', () async {
      await CitaRepository.agendar('ana', cita(vet: 'vet1'));
      final c = (await CitaRepository.stream('ana').first).single;

      await CitaRepository.cancelar(c);

      final despues = (await CitaRepository.stream('ana').first).single;
      expect(despues.estado, EstadoCita.cancelada);
      expect(despues.esProxima, isFalse);
      expect(await CitaRepository.horasOcupadas('vet1', '2030-01-10'), isEmpty);
      // El horario vuelve a estar disponible para otra persona.
      await CitaRepository.agendar('beto', cita(vet: 'vet1'));
    });

    test('el admin asigna una cita sin veterinario', () async {
      await CitaRepository.agendar('ana', cita());
      final c = (await CitaRepository.streamTodas().first).single;
      expect(c.duenoUid, 'ana');

      await CitaRepository.asignar(c, vet1);

      final despues = (await CitaRepository.stream('ana').first).single;
      expect(despues.veterinarioId, 'vet1');
      expect(despues.veterinarioNombre, 'Vet Uno');
      expect(await CitaRepository.horasOcupadas('vet1', '2030-01-10'), {'09:00'});
      expect((await CitaRepository.streamPorVeterinario('vet1').first).single.id, c.id);
    });

    test('no se asigna a un veterinario con ese horario ocupado', () async {
      await CitaRepository.agendar('ana', cita(vet: 'vet1'));
      await CitaRepository.agendar('beto', cita());
      final sinVet = (await CitaRepository.stream('beto').first).single;

      await expectLater(CitaRepository.asignar(sinVet, vet1), throwsA(isA<OperacionException>()));
      expect((await CitaRepository.stream('beto').first).single.sinAsignar, isTrue);
    });

    test('reasignar libera el horario del veterinario anterior', () async {
      await CitaRepository.agendar('ana', cita(vet: 'vet1'));
      final c = (await CitaRepository.stream('ana').first).single;

      await CitaRepository.asignar(c, vet2);

      expect(await CitaRepository.horasOcupadas('vet1', '2030-01-10'), isEmpty);
      expect(await CitaRepository.horasOcupadas('vet2', '2030-01-10'), {'09:00'});
    });

    test('el veterinario marca atendida con notas y puede reabrir', () async {
      await CitaRepository.agendar('ana', cita(vet: 'vet1'));
      final c = (await CitaRepository.stream('ana').first).single;

      await CitaRepository.marcarAtendida(c, notas: '  Vacuna aplicada sin novedad ');
      var d = (await CitaRepository.stream('ana').first).single;
      expect(d.estado, EstadoCita.atendida);
      expect(d.notas, 'Vacuna aplicada sin novedad');

      await CitaRepository.reabrir(c);
      d = (await CitaRepository.stream('ana').first).single;
      expect(d.estado, EstadoCita.pendiente);
    });

    test('las citas antiguas (sin estado ni id de mascota) se siguen leyendo', () async {
      await db.collection('usuarios/ana/citas').add({
        'mascota': 'Luna', 'servicio': 'Control', 'fecha': '2030-02-01', 'hora': '08:00',
      });
      final c = (await CitaRepository.streamTodas().first).single;
      expect(c.estado, EstadoCita.pendiente);
      expect(c.sinAsignar, isTrue);
      final luna = MascotaModel(id: 'm1', nombre: 'Luna');
      expect(c.mascotaEn([MascotaModel(id: 'm2', nombre: 'Rocky'), luna]), same(luna));
    });

    test('la mascota se encuentra por id aunque cambie de nombre', () {
      final c = cita();
      final renombrada = MascotaModel(id: 'm1', nombre: 'Lunita');
      final homonima = MascotaModel(id: 'm9', nombre: 'Luna');
      expect(c.mascotaEn([homonima, renombrada]), same(renombrada));
    });
  });

  group('veterinarios', () {
    test('al agendar solo se ofrecen veterinarios activos', () async {
      await UsuarioRepository.crear('vet1', vet1);
      await UsuarioRepository.crear('vet2', vet2);
      await UsuarioRepository.crear('ana', UsuarioModel(nombre: 'Ana'));
      await UsuarioRepository.cambiarActivo('vet2', false);

      final vets = await UsuarioRepository.veterinariosOnce();
      expect(vets.map((v) => v.uid), ['vet1']);
    });

    test('editar un veterinario no toca su rol ni sus demás datos', () async {
      await UsuarioRepository.crear('vet1', vet1);
      await UsuarioRepository.actualizarVeterinario('vet1',
          nombre: 'Laura', apellido: 'Ríos', especialidad: 'Felinos');

      final v = (await UsuarioRepository.obtener('vet1'))!;
      expect(v.nombreCompleto, 'Laura Ríos');
      expect(v.especialidad, 'Felinos');
      expect(v.rol, 'veterinario');
      expect(v.activo, isTrue);
    });
  });

  group('tienda', () {
    Future<ProductoModel> producto(String id, {int stock = 5, double precio = 20000, bool activo = true}) async {
      final p = ProductoModel(id: id, nombre: 'Producto $id', precio: precio, stock: stock, activo: activo);
      await db.collection('productos').doc(id).set(p.toFirestore());
      return p;
    }

    Future<int> stockDe(String id) async =>
        (await db.collection('productos').doc(id).get()).data()!['stock'] as int;

    test('estados del producto según stock y visibilidad', () {
      ProductoModel p(int stock, {bool activo = true}) =>
          ProductoModel(nombre: 'x', stock: stock, activo: activo);
      expect(p(20).estado, EstadoProducto.disponible);
      expect(p(5).estado, EstadoProducto.stockBajo);
      expect(p(1).estado, EstadoProducto.stockBajo);
      expect(p(0).estado, EstadoProducto.agotado);
      expect(p(20, activo: false).estado, EstadoProducto.inactivo);
      expect(p(0).sePuedeComprar, isFalse);
      expect(p(20, activo: false).sePuedeComprar, isFalse);
    });

    test('el carrito no deja pasar del stock ni agregar agotados', () async {
      final p = await producto('p1', stock: 2);
      await CarritoRepository.agregar('ana', p);
      await CarritoRepository.agregar('ana', p);
      await expectLater(CarritoRepository.agregar('ana', p), throwsA(isA<OperacionException>()));
      expect((await CarritoRepository.stream('ana').first).single.cantidad, 2);

      final agotado = await producto('p2', stock: 0);
      await expectLater(CarritoRepository.agregar('ana', agotado), throwsA(isA<OperacionException>()));

      await CarritoRepository.decrementar('ana', 'p1');
      await CarritoRepository.decrementar('ana', 'p1');
      expect(await CarritoRepository.stream('ana').first, isEmpty);
    });

    test('comprar descuenta stock, crea el pedido pendiente y vacía el carrito', () async {
      final p1 = await producto('p1', stock: 5, precio: 20000);
      final p2 = await producto('p2', stock: 3, precio: 5000);
      await CarritoRepository.agregar('ana', p1);
      await CarritoRepository.agregar('ana', p1);
      await CarritoRepository.agregar('ana', p2);
      final carrito = await CarritoRepository.stream('ana').first;

      final pedido = await CarritoRepository.confirmarPedido('ana', carrito, clienteNombre: 'Ana Paz');

      expect(pedido.total, 45000);
      expect(pedido.estado, EstadoPedido.pendiente);
      expect(await stockDe('p1'), 3);
      expect(await stockDe('p2'), 2);
      expect(await CarritoRepository.stream('ana').first, isEmpty);
      final guardado = (await CarritoRepository.streamPedidos('ana').first).single;
      expect(guardado.unidades, 3);
      expect(guardado.clienteNombre, 'Ana Paz');
      expect((await CarritoRepository.streamTodosLosPedidos().first).single.uid, 'ana');
    });

    test('se cobra el precio vigente del catálogo, no el que guardó el carrito', () async {
      final p = await producto('p1', precio: 20000);
      await CarritoRepository.agregar('ana', p);
      // El carrito queda con un precio viejo o manipulado.
      await db.doc('usuarios/ana/carrito/p1').update({'precio': 1});
      await db.doc('productos/p1').update({'precio': 25000});

      final pedido = await CarritoRepository.confirmarPedido(
          'ana', await CarritoRepository.stream('ana').first);

      expect(pedido.total, 25000);
      expect(pedido.items.single.precio, 25000);
    });

    test('si no alcanza el stock no se compra nada', () async {
      final p1 = await producto('p1', stock: 5);
      final p2 = await producto('p2', stock: 2);
      await CarritoRepository.agregar('ana', p1);
      await CarritoRepository.agregar('ana', p2);
      await CarritoRepository.agregar('ana', p2);
      final carrito = await CarritoRepository.stream('ana').first;
      // Otra persona se lleva una unidad de p2 mientras tanto.
      await db.doc('productos/p2').update({'stock': 1});

      await expectLater(
        CarritoRepository.confirmarPedido('ana', carrito),
        throwsA(isA<OperacionException>().having((e) => e.mensaje, 'mensaje', contains('Solo quedan 1'))),
      );
      expect(await stockDe('p1'), 5);
      expect(await CarritoRepository.streamPedidos('ana').first, isEmpty);
      expect(await CarritoRepository.stream('ana').first, hasLength(2));
    });

    test('no se compra un producto oculto, eliminado o agotado', () async {
      final p = await producto('p1');
      await CarritoRepository.agregar('ana', p);
      final carrito = await CarritoRepository.stream('ana').first;

      await db.doc('productos/p1').update({'activo': false});
      await expectLater(CarritoRepository.confirmarPedido('ana', carrito), throwsA(isA<OperacionException>()));

      await db.doc('productos/p1').update({'activo': true, 'stock': 0});
      await expectLater(CarritoRepository.confirmarPedido('ana', carrito), throwsA(isA<OperacionException>()));

      await db.doc('productos/p1').delete();
      await expectLater(CarritoRepository.confirmarPedido('ana', carrito), throwsA(isA<OperacionException>()));

      await expectLater(CarritoRepository.confirmarPedido('ana', []), throwsA(isA<OperacionException>()));
    });

    test('el admin avanza el estado; cancelar devuelve el stock una sola vez', () async {
      final p = await producto('p1', stock: 5);
      await CarritoRepository.agregar('ana', p);
      await CarritoRepository.agregar('ana', p);
      final pedido = await CarritoRepository.confirmarPedido(
          'ana', await CarritoRepository.stream('ana').first);
      expect(await stockDe('p1'), 3);

      await CarritoRepository.cambiarEstado(pedido, EstadoPedido.listo);
      expect((await CarritoRepository.streamPedidos('ana').first).single.estado, EstadoPedido.listo);
      expect(await stockDe('p1'), 3);

      await CarritoRepository.cambiarEstado(pedido, EstadoPedido.cancelado);
      expect(await stockDe('p1'), 5);
      await CarritoRepository.cambiarEstado(pedido, EstadoPedido.cancelado);
      expect(await stockDe('p1'), 5);

      await expectLater(
        CarritoRepository.cambiarEstado(pedido, EstadoPedido.entregado),
        throwsA(isA<OperacionException>()),
      );
    });
  });
}
