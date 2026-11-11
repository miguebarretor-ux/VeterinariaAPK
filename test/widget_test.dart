import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:huellitas_veterinaria/main.dart';
import 'package:huellitas_veterinaria/mascota_model.dart';
import 'package:huellitas_veterinaria/registro_repository.dart';

/// Repositorio de prueba: guarda lo recibido y puede fallar a propósito.
class _RepoFalso implements RegistroRepository {
  final List<UsuarioModel> recibidos = [];
  int fallosPendientes;
  _RepoFalso({this.fallosPendientes = 0});

  @override
  Future<void> registrar(UsuarioModel usuario) async {
    if (fallosPendientes > 0) {
      fallosPendientes--;
      throw const RegistroException('Ese correo ya tiene una cuenta.');
    }
    recibidos.add(usuario);
  }
}

Finder _campo(String etiqueta) => find.widgetWithText(TextField, etiqueta);

Future<void> _tocar(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _escribir(WidgetTester tester, String etiqueta, String texto) async {
  await tester.ensureVisible(_campo(etiqueta));
  await tester.enterText(_campo(etiqueta), texto);
  await tester.pump();
}

Future<void> _llenarSobreTi(WidgetTester tester) async {
  await _escribir(tester, 'Nombre', 'Sofía');
  await _escribir(tester, 'Apellido', 'Peña');
  await _escribir(tester, 'Número de documento', '1020304050');
  await _tocar(tester, find.text('Continuar'));
}

Future<void> _llenarCuenta(WidgetTester tester) async {
  await _escribir(tester, 'Correo electrónico', 'Sofia@Correo.com');
  await _escribir(tester, 'Contraseña', 'huellitas1');
  await _escribir(tester, 'Repite la contraseña', 'huellitas1');
  await _tocar(tester, find.text('Continuar'));
}

void main() {
  testWidgets('abre en el paso 1 con el progreso visible', (tester) async {
    await tester.pumpWidget(HuellitasApp(repository: _RepoFalso()));

    expect(find.text('Crear cuenta'), findsOneWidget);
    expect(find.text('PASO 1 DE 3'), findsOneWidget);
    expect(find.text('Sobre ti'), findsOneWidget);
    expect(find.text('Atrás'), findsNothing);
  });

  testWidgets('no avanza con campos vacíos y los errores se corrigen al escribir', (tester) async {
    await tester.pumpWidget(HuellitasApp(repository: _RepoFalso()));

    await _tocar(tester, find.text('Continuar'));
    expect(find.text('PASO 1 DE 3'), findsOneWidget);
    expect(find.text('Escribe tu nombre'), findsOneWidget);
    expect(find.text('Escribe tu apellido'), findsOneWidget);
    expect(find.text('Escribe tu número de documento'), findsOneWidget);

    await _escribir(tester, 'Nombre', 'Sofía');
    await tester.pumpAndSettle();
    expect(find.text('Escribe tu nombre'), findsNothing);
  });

  testWidgets('el número de documento solo acepta dígitos salvo en pasaporte', (tester) async {
    await tester.pumpWidget(HuellitasApp(repository: _RepoFalso()));

    await _escribir(tester, 'Número de documento', 'AB12.345 678');
    expect(find.text('12345678'), findsOneWidget);

    await _tocar(tester, find.text('Cédula de ciudadanía'));
    await tester.tap(find.text('Pasaporte').last);
    await tester.pumpAndSettle();
    await _escribir(tester, 'Número de documento', 'AB12.345 678');
    expect(find.text('AB12345678'), findsOneWidget);
    expect(find.text('Letras y números, sin espacios'), findsOneWidget);
  });

  testWidgets('la contraseña muestra requisitos en vivo y valida la confirmación', (tester) async {
    await tester.pumpWidget(HuellitasApp(repository: _RepoFalso()));
    await _llenarSobreTi(tester);
    expect(find.text('PASO 2 DE 3'), findsOneWidget);

    expect(find.byIcon(Icons.check_circle_rounded), findsNothing);
    await _escribir(tester, 'Contraseña', 'huellitas');
    expect(find.byIcon(Icons.check_circle_rounded), findsNWidgets(2));
    await _escribir(tester, 'Contraseña', 'huellitas1');
    expect(find.byIcon(Icons.check_circle_rounded), findsNWidgets(3));

    await _escribir(tester, 'Correo electrónico', 'sofia@correo.com');
    await _escribir(tester, 'Repite la contraseña', 'huellitas2');
    await _tocar(tester, find.text('Continuar'));
    expect(find.text('Las contraseñas no coinciden'), findsOneWidget);
    expect(find.text('PASO 2 DE 3'), findsOneWidget);
  });

  testWidgets('se puede mostrar y ocultar la contraseña', (tester) async {
    await tester.pumpWidget(HuellitasApp(repository: _RepoFalso()));
    await _llenarSobreTi(tester);

    bool oculta() => tester.widget<EditableText>(
          find.descendant(of: _campo('Contraseña'), matching: find.byType(EditableText)),
        ).obscureText;

    expect(oculta(), isTrue);
    await _tocar(tester, find.byTooltip('Mostrar contraseña'));
    expect(oculta(), isFalse);
    await _tocar(tester, find.byTooltip('Ocultar contraseña'));
    expect(oculta(), isTrue);
  });

  testWidgets('volver atrás conserva lo escrito', (tester) async {
    await tester.pumpWidget(HuellitasApp(repository: _RepoFalso()));
    await _llenarSobreTi(tester);
    await _escribir(tester, 'Correo electrónico', 'sofia@correo.com');

    await _tocar(tester, find.text('Atrás'));
    expect(find.text('PASO 1 DE 3'), findsOneWidget);
    expect(find.text('Sofía'), findsOneWidget);
    expect(find.text('1020304050'), findsOneWidget);

    await _tocar(tester, find.text('Continuar'));
    expect(find.text('sofia@correo.com'), findsOneWidget);
  });

  testWidgets('registro completo con mascota llega a la confirmación', (tester) async {
    final repo = _RepoFalso();
    await tester.pumpWidget(HuellitasApp(repository: repo));
    await _llenarSobreTi(tester);
    await _llenarCuenta(tester);
    expect(find.text('PASO 3 DE 3'), findsOneWidget);

    // Con mascota, los datos obligatorios se exigen.
    await _tocar(tester, find.text('Crear mi cuenta'));
    expect(find.text('Escribe el nombre de tu mascota'), findsOneWidget);
    expect(find.text('Escribe la edad'), findsOneWidget);
    expect(repo.recibidos, isEmpty);

    await _escribir(tester, 'Nombre de tu mascota', 'Luna');
    await _tocar(tester, find.text('Gato'));
    await _escribir(tester, 'Edad', '5');
    await _tocar(tester, find.text('Meses'));
    await _escribir(tester, 'Peso en kg (opcional)', '2,4');
    await _tocar(tester, find.text('Crear mi cuenta'));

    expect(find.text('¡Hola, Sofía!'), findsOneWidget);
    expect(find.text('sofia@correo.com'), findsOneWidget);
    expect(find.text('Luna'), findsOneWidget);
    expect(find.text('Gato · 5 meses'), findsOneWidget);

    final json = repo.recibidos.single.toJson();
    expect(json['nombre'], 'Sofía');
    expect(json['numeroDocumento'], '1020304050');
    expect(json['correo'], 'sofia@correo.com');
    expect(json['tieneMascota'], isTrue);
    expect(json['mascota'], {
      'nombre': 'Luna',
      'tipo': 'Gato',
      'edad': 5,
      'unidadEdad': 'meses',
      'peso': 2.4,
      'raza': '',
    });
  });

  testWidgets('"Otro" pide la especie', (tester) async {
    final repo = _RepoFalso();
    await tester.pumpWidget(HuellitasApp(repository: repo));
    await _llenarSobreTi(tester);
    await _llenarCuenta(tester);

    expect(_campo('¿Qué animal es?'), findsNothing);
    await _tocar(tester, find.text('Otro'));
    await _escribir(tester, 'Nombre de tu mascota', 'Copito');
    await _escribir(tester, 'Edad', '2');
    await _tocar(tester, find.text('Crear mi cuenta'));
    expect(find.text('Cuéntanos qué animal es'), findsOneWidget);

    // La edad se valida según la unidad y el error se corrige al cambiarla.
    await _escribir(tester, 'Edad', '0');
    await _tocar(tester, find.text('Crear mi cuenta'));
    expect(find.text('Si tiene menos de un año, cambia a meses'), findsOneWidget);
    await _tocar(tester, find.text('Meses'));
    expect(find.text('Si tiene menos de un año, cambia a meses'), findsNothing);
    await _tocar(tester, find.text('Años'));
    await _escribir(tester, 'Edad', '2');

    await _escribir(tester, '¿Qué animal es?', 'Conejo');
    await _tocar(tester, find.text('Crear mi cuenta'));
    expect(find.text('Conejo · 2 años'), findsOneWidget);
    expect(repo.recibidos.single.mascota!.especie, 'Conejo');
  });

  testWidgets('sin mascota se registra sin pedir sus datos', (tester) async {
    final repo = _RepoFalso();
    await tester.pumpWidget(HuellitasApp(repository: repo));
    await _llenarSobreTi(tester);
    await _llenarCuenta(tester);

    await _tocar(tester, find.text('Todavía no'));
    expect(_campo('Nombre de tu mascota'), findsNothing);
    await _tocar(tester, find.text('Crear mi cuenta'));

    expect(find.text('¡Hola, Sofía!'), findsOneWidget);
    final json = repo.recibidos.single.toJson();
    expect(json['tieneMascota'], isFalse);
    expect(json.containsKey('mascota'), isFalse);
  });

  testWidgets('si el registro falla, avisa y permite reintentar sin perder datos', (tester) async {
    final repo = _RepoFalso(fallosPendientes: 1);
    await tester.pumpWidget(HuellitasApp(repository: repo));
    await _llenarSobreTi(tester);
    await _llenarCuenta(tester);
    await _tocar(tester, find.text('Todavía no'));

    await _tocar(tester, find.text('Crear mi cuenta'));
    expect(find.text('Ese correo ya tiene una cuenta.'), findsOneWidget);
    expect(find.text('PASO 3 DE 3'), findsOneWidget);
    expect(repo.recibidos, isEmpty);

    await _tocar(tester, find.text('Crear mi cuenta'));
    expect(find.text('¡Hola, Sofía!'), findsOneWidget);
    expect(repo.recibidos, hasLength(1));
  });

  testWidgets('mientras se envía, el botón se bloquea para evitar registros dobles', (tester) async {
    await tester.pumpWidget(const HuellitasApp(
      repository: RegistroSimuladoRepository(demora: Duration(seconds: 1)),
    ));
    await _llenarSobreTi(tester);
    await _llenarCuenta(tester);
    await _tocar(tester, find.text('Todavía no'));

    await tester.ensureVisible(find.text('Crear mi cuenta'));
    await tester.tap(find.text('Crear mi cuenta'));
    await tester.pump();
    expect(find.text('Creando tu cuenta…'), findsOneWidget);
    expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed, isNull);

    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('¡Hola, Sofía!'), findsOneWidget);
  });
}
