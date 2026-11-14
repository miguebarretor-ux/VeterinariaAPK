import 'package:cloud_firestore/cloud_firestore.dart';

// ── Modelo ─────────────────────────────────────────────────────────────────────

class ServicioModel {
  String? id;
  String nombre;
  String descripcion;
  double precio;
  bool activo;

  ServicioModel({
    this.id,
    required this.nombre,
    this.descripcion = '',
    this.precio = 0,
    this.activo = true,
  });

  factory ServicioModel.fromFirestore(String id, Map<String, dynamic> d) =>
      ServicioModel(
        id: id,
        nombre: d['nombre'] ?? '',
        descripcion: d['descripcion'] ?? '',
        precio: (d['precio'] as num?)?.toDouble() ?? 0,
        activo: d['activo'] ?? true,
      );

  Map<String, dynamic> toFirestore() => {
        'nombre': nombre,
        'descripcion': descripcion,
        'precio': precio,
        'activo': activo,
      };
}

// ── Modelo catálogo vacunas ────────────────────────────────────────────────────

class VacunaCatalogoModel {
  String? id;
  String nombre;
  String descripcion;

  VacunaCatalogoModel({this.id, required this.nombre, this.descripcion = ''});

  factory VacunaCatalogoModel.fromFirestore(
          String id, Map<String, dynamic> d) =>
      VacunaCatalogoModel(
        id: id,
        nombre: d['nombre'] ?? '',
        descripcion: d['descripcion'] ?? '',
      );

  Map<String, dynamic> toFirestore() => {
        'nombre': nombre,
        'descripcion': descripcion,
      };
}

// ── Repository ─────────────────────────────────────────────────────────────────

class ServicioRepository {
  static final _servicios =
      FirebaseFirestore.instance.collection('servicios');
  static final _vacunas =
      FirebaseFirestore.instance.collection('vacunas_catalogo');

  // ── SERVICIOS ──────────────────────────────────────────────────────────────

  static Stream<List<ServicioModel>> stream() =>
      _servicios.orderBy('nombre').snapshots().map((s) => s.docs
          .map((d) => ServicioModel.fromFirestore(d.id, d.data()))
          .toList());

  // Filtra activos en cliente para evitar índice compuesto en Firestore.
  static Stream<List<ServicioModel>> streamActivos() =>
      _servicios
          .where('activo', isEqualTo: true)
          .snapshots()
          .map((s) {
            final lista = s.docs
                .map((d) => ServicioModel.fromFirestore(d.id, d.data()))
                .toList()
              ..sort((a, b) => a.nombre.compareTo(b.nombre));
            return lista;
          });

  static Future<void> agregar(ServicioModel s) =>
      _servicios.add(s.toFirestore());

  static Future<void> actualizar(ServicioModel s) =>
      _servicios.doc(s.id).update(s.toFirestore());

  static Future<void> toggleActivo(String id, bool activo) =>
      _servicios.doc(id).update({'activo': activo});

  static Future<void> eliminar(String id) => _servicios.doc(id).delete();

  // ── CATÁLOGO VACUNAS ───────────────────────────────────────────────────────

  static Stream<List<VacunaCatalogoModel>> streamVacunas() =>
      _vacunas.orderBy('nombre').snapshots().map((s) => s.docs
          .map((d) => VacunaCatalogoModel.fromFirestore(d.id, d.data()))
          .toList());

  static Future<void> agregarVacuna(VacunaCatalogoModel v) =>
      _vacunas.add(v.toFirestore());

  static Future<void> eliminarVacuna(String id) => _vacunas.doc(id).delete();

  // ── Datos iniciales (llamar una sola vez desde admin) ─────────────────────

  static Future<void> sembrarDatosIniciales() async {
    final snap = await _servicios.limit(1).get();
    if (snap.docs.isNotEmpty) return; // ya sembrado

    final servicios = [
      ServicioModel(nombre: 'Control de rutina', precio: 35000),
      ServicioModel(nombre: 'Vacunación', precio: 25000),
      ServicioModel(nombre: 'Consulta general', precio: 40000),
      ServicioModel(nombre: 'Peluquería', precio: 30000),
      ServicioModel(nombre: 'Urgencias', precio: 80000),
      ServicioModel(nombre: 'Desparasitación interna', precio: 20000),
      ServicioModel(nombre: 'Desparasitación externa', precio: 18000),
      ServicioModel(nombre: 'Microchip', precio: 45000),
      ServicioModel(nombre: 'Esterilización / Castración', precio: 250000),
      ServicioModel(nombre: 'Limpieza dental', precio: 90000),
      ServicioModel(nombre: 'Radiografía', precio: 120000),
      ServicioModel(nombre: 'Hospitalización', precio: 150000),
    ];
    for (final s in servicios) {
      await _servicios.add(s.toFirestore());
    }

    final vacunas = [
      VacunaCatalogoModel(nombre: 'Rabia'),
      VacunaCatalogoModel(nombre: 'Parvovirus'),
      VacunaCatalogoModel(nombre: 'Moquillo'),
      VacunaCatalogoModel(nombre: 'Leptospirosis'),
      VacunaCatalogoModel(nombre: 'Hepatitis canina'),
      VacunaCatalogoModel(nombre: 'Bordetella (tos de las perreras)'),
      VacunaCatalogoModel(nombre: 'Triple felina'),
      VacunaCatalogoModel(nombre: 'Leucemia felina'),
      VacunaCatalogoModel(nombre: 'Calicivirus'),
      VacunaCatalogoModel(nombre: 'Rinotraqueítis felina'),
    ];
    for (final v in vacunas) {
      await _vacunas.add(v.toFirestore());
    }
  }
}
