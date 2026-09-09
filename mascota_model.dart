class MascotaModel {
  String nombre;
  String tipo; // 'Perro', 'Gato', 'Otro'
  int edad;
  double? peso; // opcional
  String raza;

  MascotaModel({
    this.nombre = '',
    this.tipo = 'Perro',
    this.edad = 0,
    this.peso,
    this.raza = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'tipo': tipo,
      'edad': edad,
      if (peso != null) 'peso': peso,
      'raza': raza,
    };
  }
}

class UsuarioModel {
  String tipoDocumento; // 'Cédula de ciudadanía', 'Cédula de extranjería', 'Tarjeta de identidad', 'Pasaporte'
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
