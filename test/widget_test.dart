// Tests de widgets para Huellitas Veterinaria.
//
// Esta app usa dart:html (localStorage) y está diseñada para Flutter Web.
// Los tests deben ejecutarse en Chrome:
//   flutter test --platform chrome
//
@TestOn('browser')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:huellitas_veterinaria/main.dart';

void main() {
  testWidgets('Formulario de registro carga correctamente',
      (WidgetTester tester) async {
    await tester.pumpWidget(const HuellitasApp());
    await tester.pumpAndSettle();

    expect(find.text('Crear cuenta'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Registrarse'), 100.0);
    expect(find.text('Registrarse'), findsOneWidget);
  });
}
