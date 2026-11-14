/// Opciones válidas de los campos de selección. Se usan en el formulario y en
/// los validadores para no repetir las cadenas.
class Opciones {
  static const List<String> tiposDocumento = [
    'Cédula de ciudadanía',
    'Cédula de extranjería',
    'Tarjeta de identidad',
    'Pasaporte',
  ];

  static const String pasaporte = 'Pasaporte';

  static const List<String> tiposMascota = ['Perro', 'Gato', 'Otro'];
  static const String otraMascota = 'Otro';

  static const String anios = 'años';
  static const String meses = 'meses';
  static const List<String> unidadesEdad = [anios, meses];
}

class MascotaModel {
  String nombre;
  String tipo; // 'Perro', 'Gato', 'Otro'
  String? especie; // solo cuando tipo == 'Otro' (conejo, ave, …)
  int edad;
  String unidadEdad; // 'años' o 'meses' (cachorros de menos de un año)
  double? peso; // opcional, en kg
  String raza; // opcional, '' si no se conoce

  MascotaModel({
    this.nombre = '',
    this.tipo = 'Perro',
    this.especie,
    this.edad = 0,
    this.unidadEdad = Opciones.anios,
    this.peso,
    this.raza = '',
  });

  /// Edad lista para mostrar: "3 años", "1 año", "5 meses", "menos de 1 mes".
  String get edadLegible {
    if (unidadEdad == Opciones.meses) {
      if (edad == 0) return 'menos de 1 mes';
      return edad == 1 ? '1 mes' : '$edad meses';
    }
    return edad == 1 ? '1 año' : '$edad años';
  }

  /// Peso listo para mostrar con coma decimal: "12,5 kg", "4 kg".
  String? get pesoLegible {
    final p = peso;
    if (p == null) return null;
    final texto = p == p.roundToDouble() ? p.toStringAsFixed(0) : p.toString();
    return '${texto.replaceAll('.', ',')} kg';
  }

  /// Resumen en una línea: "Gato · 5 meses · Criollo · 2,4 kg".
  String get resumen => [
        tipoLegible,
        edadLegible,
        if (raza.isNotEmpty) raza,
        if (pesoLegible != null) pesoLegible!,
      ].join(' · ');

  /// Especie lista para mostrar: "Perro", "Gato" o la especie escrita.
  String get tipoLegible {
    final otra = especie?.trim() ?? '';
    return (tipo == Opciones.otraMascota && otra.isNotEmpty) ? otra : tipo;
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'tipo': tipo,
      if (tipo == Opciones.otraMascota && especie != null) 'especie': especie,
      'edad': edad,
      'unidadEdad': unidadEdad,
      if (peso != null) 'peso': peso,
      'raza': raza,
    };
  }
}

class UsuarioModel {
  String tipoDocumento; // ver Opciones.tiposDocumento
  String numeroDocumento;
  String nombre;
  String apellido;
  String correo;
  String contrasena;
  bool tieneMascota;
  MascotaModel? mascota;

  UsuarioModel({
    this.tipoDocumento = 'Cédula de ciudadanía',
    this.numeroDocumento = '',
    this.nombre = '',
    this.apellido = '',
    this.correo = '',
    this.contrasena = '',
    this.tieneMascota = false,
    this.mascota,
  });

  Map<String, dynamic> toJson() {
    return {
      'tipoDocumento': tipoDocumento,
      'numeroDocumento': numeroDocumento,
      'nombre': nombre,
      'apellido': apellido,
      'correo': correo,
      'contrasena': contrasena,
      'tieneMascota': tieneMascota,
      if (tieneMascota && mascota != null) 'mascota': mascota!.toJson(),
    };
  }
}
