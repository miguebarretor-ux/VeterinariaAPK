import json
import urllib.request

TOKEN = "glpat-aSGzo6NtAZXf3GacA9VkdWM6MQpvOjEKdTpvdTRiaw8.01.171v4hkr4"
PROJECT_ID = "86022464"
ASSIGNEE_ID = 41716061   # nicolassandobal23-oss
MILESTONE_ID = 7647158   # Sprint 2 - Backend Firebase
BASE = f"https://gitlab.com/api/v4/projects/{PROJECT_ID}"


def api(method, path, data=None):
    url = BASE + path
    body = json.dumps(data).encode() if data else None
    req = urllib.request.Request(
        url, data=body, method=method,
        headers={"PRIVATE-TOKEN": TOKEN, "Content-Type": "application/json"}
    )
    with urllib.request.urlopen(req) as r:
        return json.loads(r.read())


def issue(title, desc, labels=""):
    r = api("POST", "/issues", {
        "title": title,
        "description": desc,
        "labels": labels,
        "assignee_ids": [ASSIGNEE_ID],
        "milestone_id": MILESTONE_ID,
    })
    print(f"  #{r['iid']} {r['title']}")
    return r["iid"]


# ── Setup Firebase ─────────────────────────────────────────────────────────────
print("=== Firebase Setup ===")

issue(
    "Backend: Configurar Firebase en el proyecto Flutter",
    (
        "## Descripcion\n"
        "Integrar Firebase como backend de la app Huellitas Veterinaria.\n"
        "Actualmente toda la persistencia usa `dart:html localStorage`, lo que limita "
        "la app a Flutter Web y no permite compartir datos entre dispositivos.\n\n"
        "## Tareas\n"
        "- [ ] Crear proyecto en Firebase Console (`huellitas-veterinaria`)\n"
        "- [ ] Habilitar Authentication (Email/Password)\n"
        "- [ ] Habilitar Cloud Firestore (modo produccion)\n"
        "- [ ] Agregar dependencias a `pubspec.yaml`:\n"
        "  ```yaml\n"
        "  firebase_core: ^3.x\n"
        "  firebase_auth: ^5.x\n"
        "  cloud_firestore: ^5.x\n"
        "  ```\n"
        "- [ ] Ejecutar `flutterfire configure` para generar `firebase_options.dart`\n"
        "- [ ] Inicializar Firebase en `lib/main.dart` antes de `runApp()`\n\n"
        "## Archivos afectados\n"
        "- `pubspec.yaml`\n"
        "- `lib/main.dart`\n"
        "- `lib/firebase_options.dart` (nuevo, generado)\n\n"
        "## Notas\n"
        "- Usar FlutterFire CLI: `dart pub global activate flutterfire_cli`\n"
        "- El archivo `firebase_options.dart` NO debe subirse si contiene secrets.\n\n"
        "## Criterios de aceptacion\n"
        "- [ ] `Firebase.initializeApp()` ejecuta sin errores en web y Android\n"
        "- [ ] Console de Firebase muestra la app conectada"
    ),
    "backend,firebase,setup,sprint-2"
)

# ── Autenticacion ──────────────────────────────────────────────────────────────
print("\n=== Autenticacion ===")

issue(
    "Backend: Servicio de autenticacion con Firebase Auth",
    (
        "## Descripcion\n"
        "Reemplazar el sistema de autenticacion basado en `localStorage` por Firebase Authentication.\n\n"
        "**Estado actual:**\n"
        "- `UsuarioRegistro.buscar(correo, contrasena)` busca en localStorage\n"
        "- `UsuarioRegistro.esAdmin(correo, contrasena)` tiene credenciales hardcodeadas\n"
        "- Contrasenas guardadas en texto plano en el JSON de localStorage\n\n"
        "## Tareas\n"
        "- [ ] Crear `lib/services/auth_service.dart` con clase `AuthService`:\n"
        "  - `Future<UserCredential> registrar(String email, String password)`\n"
        "  - `Future<UserCredential> iniciarSesion(String email, String password)`\n"
        "  - `Future<void> cerrarSesion()`\n"
        "  - `Stream<User?> get estadoAuth`\n"
        "- [ ] Reemplazar logica en `lib/login.dart`:\n"
        "  - `_entrar()` usa `AuthService.iniciarSesion()` en lugar de `UsuarioRegistro.buscar()`\n"
        "- [ ] Reemplazar logica en `lib/registro.dart`:\n"
        "  - `_registrar()` usa `AuthService.registrar()` antes de guardar en Firestore\n"
        "- [ ] Manejar rol admin via campo `rol` en Firestore (no credenciales hardcodeadas)\n"
        "- [ ] Mostrar errores de Firebase en espanol\n\n"
        "## Archivos afectados\n"
        "- `lib/login.dart`\n"
        "- `lib/registro.dart`\n"
        "- `lib/services/auth_service.dart` (nuevo)\n\n"
        "## Criterios de aceptacion\n"
        "- [ ] Registro crea usuario en Firebase Auth\n"
        "- [ ] Login autentica contra Firebase Auth\n"
        "- [ ] Sesion persiste al recargar la app\n"
        "- [ ] Cierre de sesion funciona correctamente\n"
        "- [ ] Contrasenas NO se almacenan en Firestore"
    ),
    "backend,firebase,auth,sprint-2"
)

# ── Firestore Repositorios ──────────────────────────────────────────────────────
print("\n=== Firestore - Repositorios ===")

issue(
    "Backend: Repositorio de Usuarios y Mascotas en Firestore",
    (
        "## Descripcion\n"
        "Migrar `UsuarioRegistro` y la gestion de mascotas de `localStorage` a Cloud Firestore.\n\n"
        "**Esquema Firestore:**\n"
        "```\n"
        "usuarios/{uid}\n"
        "  tipoDocumento, numeroDocumento, nombre, apellido, correo, rol\n"
        "  mascotas/{mascotaId}\n"
        "    nombre, tipo, edad, peso, raza\n"
        "```\n\n"
        "## Tareas\n"
        "- [ ] Crear `lib/repositories/usuario_repository.dart`:\n"
        "  - `Future<void> crearUsuario(String uid, UsuarioModel u)`\n"
        "  - `Future<UsuarioModel?> obtenerUsuario(String uid)`\n"
        "  - `Future<void> actualizarUsuario(String uid, UsuarioModel u)`\n"
        "  - `Future<List<UsuarioModel>> obtenerTodos()` (solo admin)\n"
        "- [ ] Crear `lib/repositories/mascota_repository.dart`:\n"
        "  - `Future<void> agregarMascota(String uid, MascotaModel m)`\n"
        "  - `Future<List<MascotaModel>> obtenerMascotas(String uid)`\n"
        "  - `Future<void> actualizarMascota(String uid, MascotaModel m)`\n"
        "  - `Future<void> eliminarMascota(String uid, String mascotaId)`\n"
        "- [ ] Eliminar `import 'dart:html'` de `lib/mascota_model.dart`\n"
        "- [ ] Eliminar clase `UsuarioRegistro` de `lib/mascota_model.dart`\n"
        "- [ ] Actualizar `lib/bienvenida.dart` para usar los repositorios\n\n"
        "## Archivos afectados\n"
        "- `lib/mascota_model.dart`\n"
        "- `lib/bienvenida.dart`\n"
        "- `lib/repositories/usuario_repository.dart` (nuevo)\n"
        "- `lib/repositories/mascota_repository.dart` (nuevo)\n\n"
        "## Criterios de aceptacion\n"
        "- [ ] Crear usuario en Firestore al registrarse\n"
        "- [ ] Leer datos del usuario al iniciar sesion\n"
        "- [ ] Agregar/editar/eliminar mascotas persiste en Firestore\n"
        "- [ ] App NO usa `dart:html` en produccion"
    ),
    "backend,firestore,usuario,mascota,sprint-2"
)

issue(
    "Backend: Repositorio de Citas en Firestore",
    (
        "## Descripcion\n"
        "Migrar `CitasRegistro` de `localStorage` a Cloud Firestore.\n\n"
        "**Estado actual en `lib/mascota_model.dart`:**\n"
        "La clase `CitasRegistro` usa `html.window.localStorage` con clave `citas_{correo}`.\n\n"
        "**Esquema Firestore:**\n"
        "```\n"
        "usuarios/{uid}/citas/{citaId}\n"
        "  mascota, servicio, fecha, hora\n"
        "```\n\n"
        "## Tareas\n"
        "- [ ] Crear `lib/repositories/cita_repository.dart`:\n"
        "  - `Future<void> agregarCita(String uid, CitaModel c)`\n"
        "  - `Stream<List<CitaModel>> obtenerCitas(String uid)`\n"
        "  - `Future<void> eliminarCita(String uid, String citaId)`\n"
        "- [ ] Agregar campo `id` a `CitaModel` para identificar documentos Firestore\n"
        "- [ ] Actualizar `lib/citas.dart` para usar `CitaRepository`\n"
        "- [ ] Actualizar `lib/inicio.dart` para leer proxima cita desde Firestore\n"
        "- [ ] Eliminar clase `CitasRegistro` de `lib/mascota_model.dart`\n\n"
        "## Archivos afectados\n"
        "- `lib/mascota_model.dart`\n"
        "- `lib/citas.dart`\n"
        "- `lib/inicio.dart`\n"
        "- `lib/repositories/cita_repository.dart` (nuevo)\n\n"
        "## Criterios de aceptacion\n"
        "- [ ] Agendar cita guarda en Firestore\n"
        "- [ ] Listado de citas carga desde Firestore en tiempo real (Stream)\n"
        "- [ ] Eliminar cita borra el documento de Firestore\n"
        "- [ ] Proxima cita en el dashboard se obtiene de Firestore"
    ),
    "backend,firestore,citas,sprint-2"
)

issue(
    "Backend: Repositorio de Vacunas en Firestore",
    (
        "## Descripcion\n"
        "Migrar `CarnetRegistro` de `localStorage` a Cloud Firestore.\n\n"
        "**Estado actual en `lib/mascota_model.dart`:**\n"
        "La clase `CarnetRegistro` usa `html.window.localStorage` con clave `carnet_{correo}_{mascotaId}`.\n\n"
        "**Esquema Firestore:**\n"
        "```\n"
        "usuarios/{uid}/mascotas/{mascotaId}/vacunas/{vacunaId}\n"
        "  nombre, fechaAplicacion, fechaVencimiento?\n"
        "```\n\n"
        "## Tareas\n"
        "- [ ] Crear `lib/repositories/vacuna_repository.dart`:\n"
        "  - `Future<void> agregarVacuna(String uid, String mascotaId, VacunaModel v)`\n"
        "  - `Stream<List<VacunaModel>> obtenerVacunas(String uid, String mascotaId)`\n"
        "  - `Future<void> eliminarVacuna(String uid, String mascotaId, String vacunaId)`\n"
        "- [ ] Agregar campo `id` a `VacunaModel`\n"
        "- [ ] Actualizar `lib/carnet.dart` para usar `VacunaRepository`\n"
        "- [ ] Actualizar `lib/admin_detalle.dart` para usar `VacunaRepository`\n"
        "- [ ] Eliminar clase `CarnetRegistro` de `lib/mascota_model.dart`\n\n"
        "## Archivos afectados\n"
        "- `lib/mascota_model.dart`\n"
        "- `lib/carnet.dart`\n"
        "- `lib/admin_detalle.dart`\n"
        "- `lib/repositories/vacuna_repository.dart` (nuevo)\n\n"
        "## Criterios de aceptacion\n"
        "- [ ] Agregar vacuna desde admin guarda en Firestore\n"
        "- [ ] Carnet de vacunas carga desde Firestore\n"
        "- [ ] Eliminar vacuna borra el documento de Firestore\n"
        "- [ ] Estado al_dia / por_vencer / vencida sigue funcionando"
    ),
    "backend,firestore,vacunas,sprint-2"
)

# ── Admin y Seguridad ──────────────────────────────────────────────────────────
print("\n=== Admin y Seguridad ===")

issue(
    "Backend: Panel admin con lectura global de Firestore",
    (
        "## Descripcion\n"
        "Actualizar el panel de administracion para leer datos de todos los usuarios desde Firestore.\n\n"
        "**Estado actual:**\n"
        "- `admin_usuarios.dart` usa `UsuarioRegistro.todos` que lee de `localStorage`\n"
        "- El rol admin esta hardcodeado con credenciales fijas\n\n"
        "## Tareas\n"
        "- [ ] Actualizar `lib/admin_usuarios.dart`:\n"
        "  - Llamar a `UsuarioRepository.obtenerTodos()` en lugar de `UsuarioRegistro.todos`\n"
        "  - Mostrar loading state mientras carga desde Firestore\n"
        "- [ ] Actualizar `lib/admin_detalle.dart`:\n"
        "  - Cargar usuario, citas y vacunas desde Firestore\n"
        "- [ ] Actualizar `lib/admin_shell.dart`:\n"
        "  - `_cerrarSesion()` usa `AuthService.cerrarSesion()`\n"
        "- [ ] Control de acceso: verificar `rol == 'admin'` en Firestore\n\n"
        "## Archivos afectados\n"
        "- `lib/admin_shell.dart`\n"
        "- `lib/admin_usuarios.dart`\n"
        "- `lib/admin_detalle.dart`\n\n"
        "## Criterios de aceptacion\n"
        "- [ ] Admin ve todos los usuarios registrados en Firestore\n"
        "- [ ] Admin puede agregar/eliminar vacunas de cualquier usuario\n"
        "- [ ] Solo usuarios con `rol == 'admin'` acceden al panel\n"
        "- [ ] Cierre de sesion admin funciona"
    ),
    "backend,admin,firestore,sprint-2"
)

issue(
    "Backend: Reglas de seguridad de Firestore",
    (
        "## Descripcion\n"
        "Definir y desplegar las reglas de seguridad de Firestore para proteger los datos.\n\n"
        "## Reglas requeridas\n"
        "- Usuario solo puede leer/escribir su propio documento `usuarios/{uid}`\n"
        "- Usuario solo puede leer/escribir sus mascotas `usuarios/{uid}/mascotas/*`\n"
        "- Usuario solo puede leer/escribir sus citas `usuarios/{uid}/citas/*`\n"
        "- Usuario solo puede leer/escribir sus vacunas `usuarios/{uid}/mascotas/{id}/vacunas/*`\n"
        "- Admin (campo `rol == 'admin'` en Firestore) puede leer todos los usuarios\n\n"
        "## Tareas\n"
        "- [ ] Crear archivo `firestore.rules` en la raiz del proyecto\n"
        "- [ ] Desplegar reglas con `firebase deploy --only firestore:rules`\n"
        "- [ ] Verificar que un usuario NO puede leer datos de otro usuario\n"
        "- [ ] Verificar que el admin SI puede leer datos de todos\n"
        "- [ ] Documentar las reglas en comentarios dentro del archivo\n\n"
        "## Archivos\n"
        "- `firestore.rules` (nuevo)\n\n"
        "## Criterios de aceptacion\n"
        "- [ ] Usuario no puede acceder a `/usuarios/{otroUid}`\n"
        "- [ ] Admin puede listar todos los usuarios\n"
        "- [ ] Reglas desplegadas en Firebase Console"
    ),
    "backend,firestore,seguridad,sprint-2"
)

print("\nTodos los issues creados exitosamente.")
