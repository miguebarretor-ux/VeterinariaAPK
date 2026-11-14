import json
import urllib.request
import urllib.parse

TOKEN = "glpat-aSGzo6NtAZXf3GacA9VkdWM6MQpvOjEKdTpvdTRiaw8.01.171v4hkr4"
PROJECT_ID = "86022464"
BASE = f"https://gitlab.com/api/v4/projects/{PROJECT_ID}"
NIC = 41716061   # nicolassandobal23-oss — backend
MIG = 41716064   # miguebarretor — frontend


def api(method, path, data=None):
    url = BASE + path
    body = json.dumps(data).encode() if data else None
    req = urllib.request.Request(
        url, data=body, method=method,
        headers={"PRIVATE-TOKEN": TOKEN, "Content-Type": "application/json"}
    )
    with urllib.request.urlopen(req) as r:
        return json.loads(r.read())


def create_issue(title, desc, assignee_id, label):
    r = api("POST", "/issues", {
        "title": title,
        "description": desc,
        "labels": label,
        "assignee_ids": [assignee_id],
    })
    print(f"  #{r['iid']} -> {r['title']}")


# ── Labels ────────────────────────────────────────────────────────────────────
try:
    api("POST", "/labels", {"name": "backend",  "color": "#5B4FBE"})
except Exception:
    pass
try:
    api("POST", "/labels", {"name": "frontend", "color": "#FC6D26"})
except Exception:
    pass

# ── BACKEND — Nicolas ─────────────────────────────────────────────────────────
print("=== BACKEND (Nicolas) ===")

create_issue(
    "[FASE 1] Fix admin login: loading state y error handling en stream",
    """## Descripcion
El `AdminUsuariosPage` no distingue entre 'cargando' y 'sin usuarios', lo que hace que el admin quede bloqueado en un empty state si el stream tarda o falla silenciosamente.

## Tareas
- [ ] Anadir `bool _cargando = true` al state de `AdminUsuariosPage`
- [ ] Cambiar `_cargando` a `false` en el primer evento del stream
- [ ] Anadir `onError` al stream con snackbar de error visible
- [ ] Mostrar indicador de carga mientras `_cargando == true`

**Archivo:** `lib/admin_usuarios.dart`""",
    NIC, "backend"
)

create_issue(
    "[FASE 2] Rol Veterinario: UsuarioModel, UsuarioRepository y Firestore Rules",
    """## Descripcion
Crear el nuevo rol `veterinario` a nivel de modelo, repositorio y reglas de seguridad.

## Tareas
- [ ] Anadir `veterinario` como rol valido en `UsuarioModel` (`lib/mascota_model.dart`)
- [ ] Actualizar `UsuarioRepository.todos()` para filtrar tambien vets del listado de usuarios regulares
- [ ] Anadir metodo `UsuarioRepository.veterinarios()` que retorne solo usuarios con rol `veterinario`
- [ ] Actualizar `firestore.rules` para permitir al admin crear/editar cuentas de vets
- [ ] Actualizar `firestore.rules` para acceso de veterinarios a citas (collectionGroup)

**Archivos:** `lib/mascota_model.dart`, `lib/repositories/usuario_repository.dart`, `firestore.rules`""",
    NIC, "backend"
)

create_issue(
    "[FASE 3] CitaModel: campo veterinarioId y CitaRepository collectionGroup",
    """## Descripcion
Actualizar el modelo de citas para soportar asignacion de veterinario y anadir query de collectionGroup.

## Tareas
- [ ] Anadir campos `veterinarioId?` y `veterinarioNombre?` a `CitaModel`
- [ ] Actualizar `CitaModel.toFirestore()` y `CitaModel.fromFirestore()`
- [ ] Anadir `CitaRepository.streamPorVeterinario(vetId)` usando `collectionGroup('citas')`
- [ ] Crear indice Firestore para el collectionGroup query
- [ ] Actualizar `firestore.rules` para el collectionGroup read de veterinarios

**Archivos:** `lib/mascota_model.dart`, `lib/repositories/cita_repository.dart`, `firestore.rules`""",
    NIC, "backend"
)

create_issue(
    "[FASE 5] Colecciones Firestore: servicios dinamicos y catalogo de vacunas",
    """## Descripcion
Crear las colecciones y repositorios para que los servicios y vacunas sean dinamicos.

## Colecciones nuevas
- `servicios`: { nombre, descripcion, precio, icono, activo }
- `vacunas_catalogo`: { nombre, descripcionBreve }

## Tareas
- [ ] Crear modelos `ServicioModel` y `VacunaCatalogoModel` en `lib/mascota_model.dart`
- [ ] Crear `lib/repositories/servicio_repository.dart` con CRUD y stream
- [ ] Crear `lib/repositories/vacuna_catalogo_repository.dart` con stream de sugerencias
- [ ] Actualizar `firestore.rules` (admin write, todos read)
- [ ] Poblar datos iniciales: 5 servicios existentes + nuevos sugeridos

**Servicios nuevos sugeridos:** Desparasitacion interna/externa, Microchip, Esterilizacion, Limpieza dental, Radiografia, Hospitalizacion""",
    NIC, "backend"
)

create_issue(
    "[FASE 6] Firestore Tienda: colecciones productos, carrito, pedidos y repositories",
    """## Descripcion
Implementar la capa de datos para la tienda.

## Colecciones Firestore
- `productos`: { nombre, descripcion, precio, stock, imagenUrl, categoria, visible }
- `usuarios/{uid}/carrito`: { productoId, nombre, precio, cantidad }
- `usuarios/{uid}/pedidos`: { items[], total, fecha, estado }

## Tareas
- [ ] Crear `ProductoModel` en `lib/mascota_model.dart`
- [ ] Crear `lib/repositories/producto_repository.dart` (CRUD admin, stream productos visibles)
- [ ] Crear `lib/repositories/carrito_repository.dart` (anadir, quitar, limpiar carrito)
- [ ] Crear `lib/repositories/pedido_repository.dart` (crear pedido, stream historial)
- [ ] Actualizar `firestore.rules` para la tienda

**Archivos nuevos:** `lib/repositories/producto_repository.dart`, `lib/repositories/carrito_repository.dart`, `lib/repositories/pedido_repository.dart`""",
    NIC, "backend"
)

# ── FRONTEND — Miguel ─────────────────────────────────────────────────────────
print("\n=== FRONTEND (Miguel) ===")

create_issue(
    "[FASE 1] Reestructurar AdminShell con NavigationBar de 4 tabs",
    """## Descripcion
El `AdminShell` actual es una sola pantalla sin navegacion. Debe restructurarse con un `BottomNavigationBar` de 4 tabs.

## Tabs requeridos
1. Usuarios (icono: people_outline)
2. Veterinarios (icono: medical_services_outlined)
3. Servicios (icono: build_outlined)
4. Tienda (icono: storefront_outlined)

## Tareas
- [ ] Convertir `AdminShell` a `StatefulWidget`
- [ ] Anadir `BottomNavigationBar` con los 4 tabs siguiendo el estilo claymorphism
- [ ] Usar `IndexedStack` para mantener el estado de cada tab al cambiar
- [ ] Anadir `AdminVeterinariosPage` como placeholder en tab 2
- [ ] Tabs de Servicios y Tienda son placeholders hasta Fase 5 y 6

**Archivo:** `lib/admin_shell.dart`
**Diseno ref:** `Identidad visual veterinaria claymorphism/repo/index.html`""",
    MIG, "frontend"
)

create_issue(
    "[FASE 2] VeterinarioShell, routing del login y pantalla de perfil",
    """## Descripcion
Crear el shell y routing para el nuevo rol `veterinario`.

## Tareas
- [ ] Crear `lib/veterinario_shell.dart` con `BottomNavigationBar` de 2 tabs: Mis Tareas / Perfil
- [ ] Actualizar `lib/login.dart`: anadir rama `else if (usuario.rol == 'veterinario')` que rutee a `VeterinarioShell`
- [ ] Crear tab de Perfil del veterinario (nombre, especialidad)
- [ ] En AdminShell tab Veterinarios: lista de vets con boton para crear nuevo vet (formulario email + contrasena)
- [ ] El formulario crea cuenta en Firebase Auth + Firestore con `rol: 'veterinario'`

**Archivos:** `lib/veterinario_shell.dart` (nuevo), `lib/login.dart`, `lib/admin_shell.dart`
**Diseno ref:** `Identidad visual veterinaria claymorphism/repo/index.html`""",
    MIG, "frontend"
)

create_issue(
    "[FASE 3] Formulario de citas: agregar selector de veterinario",
    """## Descripcion
Actualizar el formulario de agendamiento para que el usuario pueda elegir al veterinario que lo atendera.

## Tareas
- [ ] Anadir paso al bottom sheet de citas para seleccionar veterinario
- [ ] Cargar lista de vets desde `UsuarioRepository.veterinarios()`
- [ ] Mostrar nombre del vet en el dropdown/lista de seleccion
- [ ] Incluir opcion 'Sin preferencia' (veterinarioId: null)
- [ ] Mostrar nombre del vet asignado en las tarjetas de citas del usuario
- [ ] Actualizar `AdminDetallePage` para mostrar el veterinario asignado en cada cita

**Archivos:** `lib/citas.dart`, `lib/admin_detalle.dart`""",
    MIG, "frontend"
)

create_issue(
    "[FASE 4] Pantalla de tareas pendientes del veterinario",
    """## Descripcion
Pantalla principal del VeterinarioShell: el vet ve todas sus citas asignadas ordenadas por fecha.

## Tareas
- [ ] Crear `lib/veterinario_tareas.dart`
- [ ] Usar `CitaRepository.streamPorVeterinario(uid)` para obtener las citas
- [ ] Separar en dos secciones: Proximas (fechas futuras, orden ascendente) e Historial (fechas pasadas)
- [ ] Tarjeta de cita: fecha/hora, servicio, nombre del cliente, nombre + especie de la mascota
- [ ] Tap en tarjeta despliega detalle expandido con datos completos del cliente y mascota
- [ ] Empty state si no hay citas asignadas
- [ ] Loading state mientras carga el stream

**Archivo nuevo:** `lib/veterinario_tareas.dart`
**Diseno ref:** `Identidad visual veterinaria claymorphism/repo/index.html`""",
    MIG, "frontend"
)

create_issue(
    "[FASE 5] Pantalla admin: gestion de servicios y catalogo de vacunas",
    """## Descripcion
Pantalla en el AdminShell tab Servicios para gestionar los servicios disponibles y el catalogo de vacunas.

## Tareas
- [ ] Crear `lib/admin_servicios.dart`
- [ ] Lista de servicios con toggle activo/inactivo
- [ ] FAB para anadir nuevo servicio (bottom sheet: nombre, precio, descripcion, icono)
- [ ] Tap en servicio para editar o eliminar
- [ ] Seccion secundaria: catalogo de tipos de vacunas
- [ ] Actualizar `lib/citas.dart`: dropdown de servicios carga desde Firestore en vez de lista hardcodeada
- [ ] Actualizar `admin_shell.dart` para que tab Servicios muestre `AdminServiciosPage`

**Archivo nuevo:** `lib/admin_servicios.dart`
**Diseno ref:** `Identidad visual veterinaria claymorphism/repo/index.html`""",
    MIG, "frontend"
)

create_issue(
    "[FASE 6] Pantalla tienda admin (CRUD productos) y usuario (carrito + compra)",
    """## Descripcion
Implementar la tienda completa: vista admin para gestionar productos y vista usuario para comprar.

## Admin — lib/admin_tienda.dart
- [ ] Lista de productos con stock, precio y estado (visible/oculto)
- [ ] FAB para anadir producto (nombre, descripcion, precio, stock, categoria, imagen URL)
- [ ] Toggle de visibilidad por producto
- [ ] Editar/eliminar producto
- [ ] Indicador visual de stock bajo (< 5 unidades)

## Usuario — lib/user_tienda.dart
- [ ] Catalogo de productos visibles, agrupados por categoria
- [ ] Boton anadir al carrito con control de cantidad
- [ ] Icono de carrito en AppBar con badge (cantidad de items)
- [ ] Pantalla del carrito: lista de items, subtotales, total
- [ ] Boton confirmar pedido que guarda en Firestore y vacia el carrito
- [ ] Tab Tienda anadido al HomeShell del usuario
- [ ] Historial de pedidos en perfil del usuario

**Archivos nuevos:** `lib/admin_tienda.dart`, `lib/user_tienda.dart`
**Diseno ref:** `Identidad visual veterinaria claymorphism/repo/index.html`""",
    MIG, "frontend"
)

create_issue(
    "[FASE 7] Diseno claymorphism consistente en todas las pantallas nuevas",
    """## Descripcion
Garantizar que todas las pantallas nuevas sigan la identidad visual claymorphism definida.

## Referencia de diseno
- Archivo local: `Identidad visual veterinaria claymorphism/repo/index.html`
- Paleta: `ink`, `leche`, `arena`, `lavanda`, `lima`, `coral`, `menta`
- Sombras: `HuellitasTheme.claySm` / `clayXl`
- Bordes: `BorderRadius.circular(24-36)` en cards, `BorderRadius.circular(999)` en chips/pills

## Tareas
- [ ] VeterinarioShell: navbar con mismo estilo que AdminShell
- [ ] AdminShell reestructurado: BottomNavigationBar con colores del sistema
- [ ] Pantalla Tareas del Veterinario: cards con clayXl, separadores de seccion
- [ ] Pantalla Tienda admin y user: cards de productos con imagen, precio en pill lima/coral
- [ ] Pantalla Servicios admin: toggle switch con colores del sistema
- [ ] Todos los botones usan wrapper `ClayButton` de `widgets.dart`
- [ ] Todos los inputs usan `HuellitasTheme.field()`

**Referencia:** `Identidad visual veterinaria claymorphism/repo/index.html`""",
    MIG, "frontend"
)

print("\nTodos los issues del parcial final creados.")
