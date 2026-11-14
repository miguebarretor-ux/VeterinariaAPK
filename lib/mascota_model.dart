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
  bool activo;         // un veterinario inactivo no recibe citas ni puede entrar

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
    this.activo = true,
  }) : mascotas = mascotas ?? [];

  String get nombreCompleto => '$nombre $apellido'.trim();

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
      activo: data['activo'] ?? true,
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
        'activo': activo,
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

  /// Con cuántas unidades o menos se avisa de stock bajo.
  static const int umbralStockBajo = 5;

  /// Estado del producto según su stock y si está publicado.
  EstadoProducto get estado {
    if (!activo) return EstadoProducto.inactivo;
    if (stock <= 0) return EstadoProducto.agotado;
    if (stock <= umbralStockBajo) return EstadoProducto.stockBajo;
    return EstadoProducto.disponible;
  }

  /// Se puede agregar al carrito: publicado y con unidades.
  bool get sePuedeComprar => activo && stock > 0;
}

enum EstadoProducto {
  disponible('Disponible'),
  stockBajo('Stock bajo'),
  agotado('Agotado'),
  inactivo('Oculto');

  final String etiqueta;
  const EstadoProducto(this.etiqueta);
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

// ─── PEDIDO ───────────────────────────────────────────────────────────────────

/// Estados por los que pasa un pedido de la tienda.
enum EstadoPedido {
  pendiente('pendiente', 'Pendiente'),
  listo('listo', 'Listo para recoger'),
  entregado('entregado', 'Entregado'),
  cancelado('cancelado', 'Cancelado');

  final String valor; // lo que se guarda en Firestore
  final String etiqueta;
  const EstadoPedido(this.valor, this.etiqueta);

  static EstadoPedido desde(String? v) => EstadoPedido.values
      .firstWhere((e) => e.valor == v, orElse: () => EstadoPedido.pendiente);
}

class PedidoModel {
  String? id;
  String uid; // dueño del pedido
  String clienteNombre;
  String fecha; // ISO 8601
  double total;
  EstadoPedido estado;
  List<CarritoItemModel> items;

  PedidoModel({
    this.id,
    required this.uid,
    this.clienteNombre = '',
    required this.fecha,
    required this.total,
    this.estado = EstadoPedido.pendiente,
    required this.items,
  });

  factory PedidoModel.fromFirestore(
          String id, String uid, Map<String, dynamic> d) =>
      PedidoModel(
        id: id,
        uid: (d['uid'] as String?) ?? uid,
        clienteNombre: d['clienteNombre'] ?? '',
        fecha: d['fecha'] ?? '',
        total: (d['total'] as num?)?.toDouble() ?? 0,
        estado: EstadoPedido.desde(d['estado'] as String?),
        items: ((d['items'] as List?) ?? [])
            .map((i) => CarritoItemModel.fromFirestore(
                (i as Map)['productoId'] ?? '', Map<String, dynamic>.from(i)))
            .toList(),
      );

  Map<String, dynamic> toFirestore() => {
        'uid': uid,
        'clienteNombre': clienteNombre,
        'fecha': fecha,
        'total': total,
        'estado': estado.valor,
        'items': items
            .map((i) => {'productoId': i.productoId, ...i.toFirestore()})
            .toList(),
      };

  int get unidades => items.fold(0, (acc, i) => acc + i.cantidad);

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

// ─── CITA ──────────────────────────────────────────────────────────────────────

/// Estados de una cita. Las citas guardadas antes de existir este campo se
/// leen como pendientes.
enum EstadoCita {
  pendiente('pendiente', 'Pendiente'),
  atendida('atendida', 'Atendida'),
  cancelada('cancelada', 'Cancelada');

  final String valor; // lo que se guarda en Firestore
  final String etiqueta;
  const EstadoCita(this.valor, this.etiqueta);

  static EstadoCita desde(String? v) => EstadoCita.values
      .firstWhere((e) => e.valor == v, orElse: () => EstadoCita.pendiente);
}

class CitaModel {
  String? id;                 // Firestore document ID
  String? duenoUid;           // UID del dueño (usuarios/{duenoUid}/citas/{id})
  String mascota;             // nombre, para mostrar
  String? mascotaId;          // id de la mascota: el vínculo real
  String servicio;
  String fecha;               // yyyy-MM-dd
  String hora;                // HH:mm
  String? veterinarioId;      // UID del veterinario asignado (null = sin asignar)
  String? veterinarioNombre;  // Nombre completo del veterinario asignado
  EstadoCita estado;
  String notas;               // observaciones del veterinario al atender

  CitaModel({
    this.id,
    this.duenoUid,
    required this.mascota,
    this.mascotaId,
    required this.servicio,
    required this.fecha,
    required this.hora,
    this.veterinarioId,
    this.veterinarioNombre,
    this.estado = EstadoCita.pendiente,
    this.notas = '',
  });

  factory CitaModel.fromJson(Map<String, dynamic> json) => CitaModel(
        id: json['id'],
        duenoUid: json['duenoUid'],
        mascota: json['mascota'] ?? '',
        mascotaId: json['mascotaId'],
        servicio: json['servicio'] ?? '',
        fecha: json['fecha'] ?? '',
        hora: json['hora'] ?? '',
        veterinarioId: json['veterinarioId'],
        veterinarioNombre: json['veterinarioNombre'],
        estado: EstadoCita.desde(json['estado'] as String?),
        notas: json['notas'] ?? '',
      );

  /// `veterinarioId` se guarda siempre, aunque sea null, para poder
  /// distinguir "sin asignar" de un documento antiguo.
  Map<String, dynamic> toJson() => {
        if (duenoUid != null) 'duenoUid': duenoUid,
        'mascota': mascota,
        if (mascotaId != null) 'mascotaId': mascotaId,
        'servicio': servicio,
        'fecha': fecha,
        'hora': hora,
        'veterinarioId': veterinarioId,
        'veterinarioNombre': veterinarioNombre,
        'estado': estado.valor,
        'notas': notas,
      };

  bool get sinAsignar => veterinarioId == null || veterinarioId!.isEmpty;

  /// Momento exacto de la cita; null si la fecha u hora no se pueden leer.
  DateTime? get fechaHora {
    try {
      final d = DateTime.parse(fecha);
      final p = hora.split(':');
      return DateTime(d.year, d.month, d.day, int.parse(p[0]), int.parse(p[1]));
    } catch (_) {
      return null;
    }
  }

  /// Para ordenar por fecha y hora ("2026-03-05 09:00").
  String get claveOrden => '$fecha $hora';

  /// Pendiente y de hoy en adelante: lo que aún hay que atender.
  bool get esProxima {
    if (estado != EstadoCita.pendiente) return false;
    try {
      final d = DateTime.parse(fecha);
      final hoy = DateTime.now();
      return !d.isBefore(DateTime(hoy.year, hoy.month, hoy.day));
    } catch (_) {
      return false;
    }
  }

  /// La mascota de esta cita dentro de la lista del dueño: por id y, en
  /// citas antiguas sin id, por nombre.
  MascotaModel? mascotaEn(List<MascotaModel> mascotas) {
    for (final m in mascotas) {
      if (mascotaId != null ? m.id == mascotaId : m.nombre == mascota) return m;
    }
    return null;
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
