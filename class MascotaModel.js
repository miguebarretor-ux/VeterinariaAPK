class MascotaModel {
  constructor({
    nombre = '',
    tipo = 'Perro',
    especie = null, // solo cuando tipo === 'Otro'
    edad = 0,
    unidadEdad = 'años', // 'años' o 'meses'
    peso = null,
    raza = '',
  } = {}) {
    this.nombre = nombre;
    this.tipo = tipo;
    this.especie = especie;
    this.edad = edad;
    this.unidadEdad = unidadEdad;
    this.peso = peso;
    this.raza = raza;
  }

  toJson() {
    const json = {
      nombre: this.nombre,
      tipo: this.tipo,
      edad: this.edad,
      unidadEdad: this.unidadEdad,
      raza: this.raza,
    };

    if (this.tipo === 'Otro' && this.especie !== null && this.especie !== undefined) {
      json.especie = this.especie;
    }

    if (this.peso !== null && this.peso !== undefined) {
      json.peso = this.peso;
    }

    return json;
  }
}

class UsuarioModel {
  constructor({
    tipoDocumento = 'Cédula de ciudadanía',
    numeroDocumento = '',
    nombre = '',
    apellido = '',
    correo = '',
    contrasena = '',
    tieneMascota = false,
    mascota = null,
  } = {}) {
    this.tipoDocumento = tipoDocumento;
    this.numeroDocumento = numeroDocumento;
    this.nombre = nombre;
    this.apellido = apellido;
    this.correo = correo;
    this.contrasena = contrasena;
    this.tieneMascota = tieneMascota;
    this.mascota = mascota;
  }

  toJson() {
    const json = {
      tipoDocumento: this.tipoDocumento,
      numeroDocumento: this.numeroDocumento,
      nombre: this.nombre,
      apellido: this.apellido,
      correo: this.correo,
      contrasena: this.contrasena,
      tieneMascota: this.tieneMascota,
    };

    if (this.tieneMascota && this.mascota !== null && this.mascota !== undefined) {
      json.mascota = this.mascota.toJson();
    }

    return json;
  }
}
