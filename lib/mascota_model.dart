// ─── VACUNA ────────────────────────────────────────────────────────────────────

class VacunaModel {
  String nombre;
  String fechaAplicacion;   // yyyy-MM-dd
  String? fechaVencimiento; // yyyy-MM-dd o null

  VacunaModel({
    required this.nombre,
    required this.fechaAplicacion,
    this.fechaVencimiento,
  });

  factory VacunaModel.fromJson(Map<String, dynamic> json) => VacunaModel(
        nombre: json['nombre'] ?? '',
        fechaAplicacion: json['fechaAplicacion'] ?? '',
        fechaVencimiento: json['fechaVencimiento'],
      );

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'fechaAplicacion': fechaAplicacion,
        if (fechaVencimiento != null) 'fechaVencimiento': fechaVencimiento,
      };

  /// 'al_dia' | 'por_vencer' | 'vencida'
  String get estado {
    if (fechaVencimiento == null || fechaVencimiento!.isEmpty) return 'al_dia';
    try {
      final diff =
          DateTime.parse(fechaVencimiento!).difference(DateTime.now()).inDays;
      if (diff < 0) return 'vencida';
      if (diff <= 30) return 'por_vencer';
      return 'al_dia';
    } catch (_) {
      return 'al_dia';
    }
  }

  String get estadoLabel {
    switch (estado) {
      case 'vencida':
        return 'Vencida';
      case 'por_vencer':
        return 'Por vencer';
      default:
        return 'Al día';
    }
  }

  String get fechaAplicacionFmt {
    try {
      final d = DateTime.parse(fechaAplicacion);
      const m = [
        'ene', 'feb', 'mar', 'abr', 'may', 'jun',
        'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
      ];
      return '${d.day} ${m[d.month - 1]} ${d.year}';
    } catch (_) {
      return fechaAplicacion;
    }
  }
}

// ─── MASCOTA ──────────────────────────────────────────────────────────────────

class MascotaModel {
  String id;
  String nombre;
  String tipo; // 'Perro' | 'Gato' | 'Otro'
  int edad;
  double? peso;
  String raza;
  List<VacunaModel> vacunas; // guardadas en el doc Firestore del usuario

  MascotaModel({
    String? id,
    this.nombre = '',
    this.tipo = 'Perro',
    this.edad = 0,
    this.peso,
    this.raza = '',
    List<VacunaModel>? vacunas,
  })  : id = id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        vacunas = vacunas ?? [];

  factory MascotaModel.fromJson(Map<String, dynamic> json) => MascotaModel(
        id: json['id'] ?? DateTime.now().microsecondsSinceEpoch.toString(),
        nombre: json['nombre'] ?? '',
        tipo: json['tipo'] ?? 'Perro',
        edad: (json['edad'] ?? 0) as int,
        peso: json['peso'] != null ? (json['peso'] as num).toDouble() : null,
        raza: json['raza'] ?? '',
        vacunas: json['vacunas'] != null
            ? (json['vacunas'] as List)
                .map((v) => VacunaModel.fromJson(v as Map<String, dynamic>))
                .toList()
            : [],
      );

  factory MascotaModel.fromFirestore(Map<String, dynamic> data) =>
      MascotaModel.fromJson(data);

  // Serialización básica (sin vacunas) — para formularios internos
  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'tipo': tipo,
        'edad': edad,
        if (peso != null) 'peso': peso,
        'raza': raza,
      };

  // Serialización completa con vacunas — para guardar en Firestore
  Map<String, dynamic> toFirestore() => {
        'id': id,
        'nombre': nombre,
        'tipo': tipo,
        'edad': edad,
        if (peso != null) 'peso': peso,
        'raza': raza,
        'vacunas': vacunas.map((v) => v.toJson()).toList(),
      };
}

// ─── USUARIO ──────────────────────────────────────────────────────────────────

class UsuarioModel {
  String? uid; // Firebase Auth UID — ID del documento en Firestore
  String tipoDocumento;
  String numeroDocumento;
  String nombre;
  String apellido;
  String correo;
  String contrasena; // solo en memoria durante registro, NO se guarda en Firestore
  List<MascotaModel> mascotas;
  String rol;          // 'usuario' | 'admin' | 'veterinario'
  String especialidad; // solo para veterinarios

  UsuarioModel({
    this.uid,
    this.tipoDocumento = 'Cédula de ciudadanía',
    this.numeroDocumento = '',
    this.nombre = '',
    this.apellido = '',
    this.correo = '',
    this.contrasena = '',
    List<MascotaModel>? mascotas,
    this.rol = 'usuario',
    this.especialidad = '',
  }) : mascotas = mascotas ?? [];

  // ── Getters de compatibilidad ─────────────────────────────────────────────
  bool get tieneMascota => mascotas.isNotEmpty;
  MascotaModel? get mascota => mascotas.isEmpty ? null : mascotas.first;

  // ── Firestore: leer ───────────────────────────────────────────────────────
  factory UsuarioModel.fromFirestore(String uid, Map<String, dynamic> data) {
    List<MascotaModel> mascotas = [];
    if (data['mascotas'] != null) {
      mascotas = (data['mascotas'] as List)
          .map((e) => MascotaModel.fromFirestore(e as Map<String, dynamic>))
          .toList();
    }
    return UsuarioModel(
      uid: uid,
      tipoDocumento: data['tipoDocumento'] ?? 'Cédula de ciudadanía',
      numeroDocumento: data['numeroDocumento'] ?? '',
      nombre: data['nombre'] ?? '',
      apellido: data['apellido'] ?? '',
      correo: data['correo'] ?? '',
      mascotas: mascotas,
      rol: data['rol'] ?? 'usuario',
      especialidad: data['especialidad'] ?? '',
    );
  }

  // ── Firestore: escribir (sin uid, sin contrasena) ─────────────────────────
  Map<String, dynamic> toFirestore() => {
        'tipoDocumento': tipoDocumento,
        'numeroDocumento': numeroDocumento,
        'nombre': nombre,
        'apellido': apellido,
        'correo': correo,
        'rol': rol,
        'especialidad': especialidad,
        'mascotas': mascotas.map((m) => m.toFirestore()).toList(),
      };

  // ── JSON (compatibilidad) ─────────────────────────────────────────────────
  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    List<MascotaModel> mascotas = [];
    if (json['mascotas'] != null) {
      mascotas = (json['mascotas'] as List)
          .map((e) => MascotaModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (json['mascota'] != null && json['tieneMascota'] == true) {
      mascotas = [
        MascotaModel.fromJson(json['mascota'] as Map<String, dynamic>)
      ];
    }
    return UsuarioModel(
      tipoDocumento: json['tipoDocumento'] ?? 'Cédula de ciudadanía',
      numeroDocumento: json['numeroDocumento'] ?? '',
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      correo: json['correo'] ?? '',
      contrasena: json['contrasena'] ?? '',
      mascotas: mascotas,
      rol: json['rol'] ?? 'usuario',
    );
  }

  Map<String, dynamic> toJson() => {
        'tipoDocumento': tipoDocumento,
        'numeroDocumento': numeroDocumento,
        'nombre': nombre,
        'apellido': apellido,
        'correo': correo,
        'mascotas': mascotas.map((m) => m.toJson()).toList(),
        'rol': rol,
      };
}

// ─── PRODUCTO ─────────────────────────────────────────────────────────────────

class ProductoModel {
  String? id;
  String nombre;
  String descripcion;
  double precio;
  int stock;
  bool activo;

  ProductoModel({
    this.id,
    required this.nombre,
    this.descripcion = '',
    this.precio = 0,
    this.stock = 0,
    this.activo = true,
  });

  factory ProductoModel.fromFirestore(String id, Map<String, dynamic> d) =>
      ProductoModel(
        id: id,
        nombre: d['nombre'] ?? '',
        descripcion: d['descripcion'] ?? '',
        precio: (d['precio'] as num?)?.toDouble() ?? 0,
        stock: (d['stock'] as num?)?.toInt() ?? 0,
        activo: d['activo'] ?? true,
      );

  Map<String, dynamic> toFirestore() => {
        'nombre': nombre,
        'descripcion': descripcion,
        'precio': precio,
        'stock': stock,
        'activo': activo,
      };
}

// ─── CARRITO ITEM ──────────────────────────────────────────────────────────────

class CarritoItemModel {
  String productoId;
  String nombre;
  double precio;
  int cantidad;

  CarritoItemModel({
    required this.productoId,
    required this.nombre,
    required this.precio,
    required this.cantidad,
  });

  factory CarritoItemModel.fromFirestore(String id, Map<String, dynamic> d) =>
      CarritoItemModel(
        productoId: id,
        nombre: d['nombre'] ?? '',
        precio: (d['precio'] as num?)?.toDouble() ?? 0,
        cantidad: (d['cantidad'] as num?)?.toInt() ?? 1,
      );

  Map<String, dynamic> toFirestore() => {
        'nombre': nombre,
        'precio': precio,
        'cantidad': cantidad,
      };

  double get subtotal => precio * cantidad;
}

// ─── CITA ──────────────────────────────────────────────────────────────────────

class CitaModel {
  String? id;                 // Firestore document ID
  String mascota;
  String servicio;
  String fecha;               // yyyy-MM-dd
  String hora;                // HH:mm
  String? veterinarioId;      // UID del veterinario asignado (nullable)
  String? veterinarioNombre;  // Nombre completo del veterinario asignado

  CitaModel({
    this.id,
    required this.mascota,
    required this.servicio,
    required this.fecha,
    required this.hora,
    this.veterinarioId,
    this.veterinarioNombre,
  });

  factory CitaModel.fromJson(Map<String, dynamic> json) => CitaModel(
        id: json['id'],
        mascota: json['mascota'] ?? '',
        servicio: json['servicio'] ?? '',
        fecha: json['fecha'] ?? '',
        hora: json['hora'] ?? '',
        veterinarioId: json['veterinarioId'],
        veterinarioNombre: json['veterinarioNombre'],
      );

  Map<String, dynamic> toJson() => {
        'mascota': mascota,
        'servicio': servicio,
        'fecha': fecha,
        'hora': hora,
        if (veterinarioId != null) 'veterinarioId': veterinarioId,
        if (veterinarioNombre != null) 'veterinarioNombre': veterinarioNombre,
      };

  bool get esProxima {
    try {
      final d = DateTime.parse(fecha);
      final hoy = DateTime.now();
      return !d.isBefore(DateTime(hoy.year, hoy.month, hoy.day));
    } catch (_) {
      return false;
    }
  }

  String get fechaFormateada {
    try {
      final d = DateTime.parse(fecha);
      const m = [
        'ene', 'feb', 'mar', 'abr', 'may', 'jun',
        'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
      ];
      return '${d.day} ${m[d.month - 1]} ${d.year}';
    } catch (_) {
      return fecha;
    }
  }
}
