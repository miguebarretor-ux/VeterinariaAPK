import 'package:flutter_test/flutter_test.dart';
import 'package:huellitas_veterinaria/mascota_model.dart';
import 'package:huellitas_veterinaria/validadores.dart';

void main() {
  group('nombrePersona', () {
    test('acepta nombres con tildes, ñ y compuestos', () {
      // Incluye apóstrofo tipográfico (iOS) y tilde como carácter combinado.
      for (final n in ['Sofía', 'María José', 'Peña', "O'Connor", 'Ana-Lucía', 'D’Angelo', 'Jose\u0301']) {
        expect(Validadores.nombrePersona(n, queFalta: 'tu nombre'), isNull, reason: n);
      }
    });

    test('rechaza vacío, muy corto y con números', () {
      expect(Validadores.nombrePersona('  ', queFalta: 'tu nombre'), 'Escribe tu nombre');
      expect(Validadores.nombrePersona('A', queFalta: 'tu nombre'), isNotNull);
      expect(Validadores.nombrePersona('Ana3', queFalta: 'tu nombre'), isNotNull);
    });
  });

  group('documento', () {
    const cedula = 'Cédula de ciudadanía';

    test('cédula: solo dígitos, entre 6 y 11', () {
      expect(Validadores.documento(cedula, '1020304050'), isNull);
      expect(Validadores.documento(cedula, ''), isNotNull);
      expect(Validadores.documento(cedula, '12345'), isNotNull);
      expect(Validadores.documento(cedula, '123456789012'), isNotNull);
      expect(Validadores.documento(cedula, '10.203.040'), isNotNull);
      expect(Validadores.documento(cedula, 'AB123456'), isNotNull);
    });

    test('pasaporte: admite letras y números', () {
      expect(Validadores.documento(Opciones.pasaporte, 'AB123456'), isNull);
      expect(Validadores.documento(Opciones.pasaporte, 'AB 123'), isNotNull);
      expect(Validadores.documento(Opciones.pasaporte, 'AB1'), isNotNull);
    });
  });

  group('correo', () {
    test('acepta correos comunes', () {
      for (final c in ['sofia@correo.com', ' ana.perez+vet@mail.com.co ']) {
        expect(Validadores.correo(c), isNull, reason: c);
      }
    });

    test('rechaza los que el validador anterior dejaba pasar', () {
      for (final c in ['', '@.', 'a@b', 'a.b@c', 'sofia@correo.', 'so fia@correo.com', 'a@@b.com']) {
        expect(Validadores.correo(c), isNotNull, reason: c);
      }
    });
  });

  group('contraseña', () {
    test('exige 8 caracteres, una letra y un número', () {
      expect(Validadores.contrasena('huellitas1'), isNull);
      expect(Validadores.contrasena(''), 'Crea una contraseña');
      expect(Validadores.contrasena('abc12'), isNotNull);
      expect(Validadores.contrasena('solamenteletras'), isNotNull);
      expect(Validadores.contrasena('1234567890'), isNotNull);
    });

    test('la confirmación debe coincidir', () {
      expect(Validadores.confirmacion('huellitas1', 'huellitas1'), isNull);
      expect(Validadores.confirmacion('', 'huellitas1'), 'Repite tu contraseña');
      expect(Validadores.confirmacion('huellitas2', 'huellitas1'), 'Las contraseñas no coinciden');
    });
  });

  group('edad', () {
    test('en años: de 1 a 100', () {
      expect(Validadores.edad('3', Opciones.anios), isNull);
      expect(Validadores.edad('', Opciones.anios), 'Escribe la edad');
      expect(Validadores.edad('0', Opciones.anios), contains('meses'));
      expect(Validadores.edad('101', Opciones.anios), isNotNull);
      expect(Validadores.edad('tres', Opciones.anios), isNotNull);
    });

    test('en meses: de 0 a 23', () {
      expect(Validadores.edad('0', Opciones.meses), isNull);
      expect(Validadores.edad('5', Opciones.meses), isNull);
      expect(Validadores.edad('24', Opciones.meses), contains('años'));
    });
  });

  group('peso', () {
    test('es opcional y acepta coma o punto decimal', () {
      expect(Validadores.peso(''), isNull);
      expect(Validadores.peso('4,5'), isNull);
      expect(Validadores.peso('4.5'), isNull);
      expect(Validadores.leerPeso('4,5'), 4.5);
      expect(Validadores.leerPeso(''), isNull);
    });

    test('rechaza valores que antes se perdían en silencio', () {
      expect(Validadores.peso('4,5,1'), isNotNull);
      expect(Validadores.peso('0'), isNotNull);
      expect(Validadores.peso('5000'), isNotNull);
    });
  });

  group('MascotaModel', () {
    test('edad y tipo legibles', () {
      expect(MascotaModel(edad: 1).edadLegible, '1 año');
      expect(MascotaModel(edad: 3).edadLegible, '3 años');
      expect(MascotaModel(edad: 1, unidadEdad: Opciones.meses).edadLegible, '1 mes');
      expect(MascotaModel(edad: 5, unidadEdad: Opciones.meses).edadLegible, '5 meses');
      expect(MascotaModel(edad: 0, unidadEdad: Opciones.meses).edadLegible, 'menos de 1 mes');
      expect(MascotaModel(tipo: 'Otro', especie: 'Conejo').tipoLegible, 'Conejo');
      expect(MascotaModel(tipo: 'Gato', especie: 'Conejo').tipoLegible, 'Gato');
    });

    test('toJson incluye especie solo para "Otro" y omite peso vacío', () {
      final perro = MascotaModel(nombre: 'Luna', edad: 3, especie: 'x').toJson();
      expect(perro.containsKey('especie'), isFalse);
      expect(perro.containsKey('peso'), isFalse);
      expect(perro['unidadEdad'], 'años');

      final conejo = MascotaModel(tipo: 'Otro', especie: 'Conejo', peso: 1.2).toJson();
      expect(conejo['especie'], 'Conejo');
      expect(conejo['peso'], 1.2);
    });
  });
}
