# Graph Report - VeterinariaAPK  (2026-11-15)

## Corpus Check
- 47 files · ~32,526 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 6 file(s) not represented in the graph (top: (none) 3, .rules 1, .iml 1)

## Summary
- 890 nodes · 1261 edges · 39 communities (38 shown, 1 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `1fbf4bac`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- lib/mascota_model.dart
- tienda.dart
- login.dart
- citas.dart
- admin_servicios.dart
- huellitas_theme.dart
- admin_tienda.dart
- admin_veterinarios.dart
- admin_shell.dart
- veterinario_tareas.dart
- widgets.dart
- rules.test.cjs
- servicio_repository.dart
- admin_detalle.dart
- carnet.dart
- admin_citas.dart
- pedidos.dart
- inicio.dart
- bienvenida.dart
- veterinario_shell.dart
- pubspec.yaml
- gitlab-token-setup.sh
- admin_usuarios.dart
- home_shell.dart
- mascota_model.dart
- cita_repository.dart
- StatelessWidget
- repositorios_test.dart
- carrito_repository.dart
- usuario_repository.dart
- mascota_model.dart
- registro.dart
- manifest.json
- db.dart
- package:flutter/material.dart
- create_issues.py
- MascotaModel
- StatefulWidget
- analysis_options.yaml

## God Nodes (most connected - your core abstractions)
1. `gitlab-token-setup.sh script` - 13 edges
2. `CitaModel` - 6 edges
3. `warn()` - 6 edges
4. `dependencies` - 5 edges
5. `finish()` - 5 edges
6. `sembrar()` - 4 edges
7. `_AdminServiciosPageState` - 4 edges
8. `VacunaModel` - 4 edges
9. `dev_dependencies` - 4 edges
10. `_clear()` - 4 edges

## Surprising Connections (you probably didn't know these)
- `_ElegirVetSheet` --inherits--> `StatefulWidget`  [EXTRACTED]
  lib/admin_citas.dart → None  _Bridges community 37 → community 15_
- `AdminDetallePage` --inherits--> `StatefulWidget`  [EXTRACTED]
  lib/admin_detalle.dart → None  _Bridges community 37 → community 13_
- `AdminServiciosPage` --inherits--> `StatefulWidget`  [EXTRACTED]
  lib/admin_servicios.dart → None  _Bridges community 37 → community 4_
- `AdminShell` --inherits--> `StatefulWidget`  [EXTRACTED]
  lib/admin_shell.dart → None  _Bridges community 37 → community 8_
- `AdminTiendaPage` --inherits--> `StatefulWidget`  [EXTRACTED]
  lib/admin_tienda.dart → None  _Bridges community 37 → community 6_

## Import Cycles
- None detected.

## Communities (39 total, 1 thin omitted)

### Community 0 - "lib/mascota_model.dart"
Cohesion: 0.03
Nodes (58): activo, apellido, cantidad, claveOrden, clienteNombre, contrasena, correo, descripcion (+50 more)

### Community 1 - "tienda.dart"
Cohesion: 0.05
Nodes (42): CarritoItemModel, _abrirCarrito, _agregar, buf, build, cantidadEnCarrito, _carrito, _CarritoSheet (+34 more)

### Community 2 - "login.dart"
Cohesion: 0.05
Nodes (28): _cargando, _contrasenaCtrl, _correoCtrl, createState, dispose, _entrar, _formKey, IniciarSesionPage (+20 more)

### Community 3 - "citas.dart"
Cohesion: 0.05
Nodes (39): _abrirForm, _actualizarOcupadas, build, _cancelar, _cargandoVets, _cargarDatos, cita, _citas (+31 more)

### Community 4 - "admin_servicios.dart"
Cohesion: 0.06
Nodes (34): AdminServiciosPage, _AdminServiciosPageState, build, _cargando, createState, _descripcion, dispose, _editarServicio (+26 more)

### Community 5 - "huellitas_theme.dart"
Cohesion: 0.06
Nodes (32): arena, cardBox, chipBox, clay, claySm, clayXl, coral, field (+24 more)

### Community 6 - "admin_tienda.dart"
Cohesion: 0.06
Nodes (32): _accesoPedidos, AdminTiendaPage, _AdminTiendaPageState, build, _cargando, createState, _descripcion, dispose (+24 more)

### Community 7 - "admin_veterinarios.dart"
Cohesion: 0.06
Nodes (30): AdminVeterinariosPage, _AdminVeterinariosPageState, _agregarVet, _apellido, build, _cambiarActivo, _cargando, _contrasenaCtrl (+22 more)

### Community 8 - "admin_shell.dart"
Cohesion: 0.06
Nodes (25): _AdminServiciosPage, AdminShell, _AdminShellState, _AdminTiendaPage, AdminVacunaSheet, _AdminVacunaSheetState, _AdminVetsPage, build (+17 more)

### Community 9 - "veterinario_tareas.dart"
Cohesion: 0.07
Nodes (30): _atender, build, _cargando, _cargarDuenos, cita, _CitaConDueno, _citas, createState (+22 more)

### Community 10 - "widgets.dart"
Cohesion: 0.07
Nodes (29): AuthLink, AvisoEnLinea, buf, build, child, ClayButton, color, colorEstadoCita (+21 more)

### Community 11 - "rules.test.cjs"
Cohesion: 0.09
Nodes (21): description, devDependencies, firebase@^12.0.0, @firebase/rules-unit-testing@^5.0.0, firebase-tools@^15.0.0, name, private, scripts (+13 more)

### Community 12 - "servicio_repository.dart"
Cohesion: 0.08
Nodes (22): activo, actualizar, agregar, agregarVacuna, descripcion, eliminar, eliminarVacuna, fromFirestore (+14 more)

### Community 13 - "admin_detalle.dart"
Cohesion: 0.09
Nodes (22): AdminDetallePage, _AdminDetallePageState, _agregarVacuna, build, cita, _CitaRow, _citas, _citasSub (+14 more)

### Community 14 - "carnet.dart"
Cohesion: 0.10
Nodes (20): _AdminNote, _alDia, build, CarnetPage, _CarnetPageState, createState, didUpdateWidget, _EmptyState (+12 more)

### Community 15 - "admin_citas.dart"
Cohesion: 0.10
Nodes (19): _asignar, build, _cancelar, _cargando, _cargar, _cargarDuenos, cita, _citas (+11 more)

### Community 16 - "pedidos.dart"
Cohesion: 0.10
Nodes (17): PedidoModel, build, _cambiar, _cargando, createState, dispose, _error, esAdmin (+9 more)

### Community 17 - "inicio.dart"
Cohesion: 0.10
Nodes (18): build, cita, _citas, color, createState, dispose, icon, initState (+10 more)

### Community 18 - "bienvenida.dart"
Cohesion: 0.10
Nodes (20): BienvenidaPage, _BienvenidaPageState, build, createState, _eliminarMascota, _formKey, _guardar, icono (+12 more)

### Community 19 - "veterinario_shell.dart"
Cohesion: 0.11
Nodes (16): build, _cerrarSesion, createState, dispose, icono, _InfoRow, initState, label (+8 more)

### Community 20 - "pubspec.yaml"
Cohesion: 0.11
Nodes (18): dependencies, cloud_firestore, firebase_auth, firebase_core, flutter, description, dev_dependencies, fake_cloud_firestore (+10 more)

### Community 21 - "gitlab-token-setup.sh"
Cohesion: 0.24
Nodes (18): ask(), ask_secret(), banner(), _clear(), confirm(), _existing(), finish(), note() (+10 more)

### Community 22 - "admin_usuarios.dart"
Cohesion: 0.12
Nodes (15): AdminUsuariosPage, _AdminUsuariosPageState, _cargando, _Chip, createState, dispose, _EmptyState, icon (+7 more)

### Community 23 - "home_shell.dart"
Cohesion: 0.12
Nodes (10): build, createState, dispose, HomeShell, _HomeShellState, initState, _irPerfil, _sub (+2 more)

### Community 24 - "mascota_model.dart"
Cohesion: 0.11
Nodes (15): apellido, contrasena, correo, edad, mascota, MascotaModel, nombre, numeroDocumento (+7 more)

### Community 25 - "cita_repository.dart"
Cohesion: 0.11
Nodes (16): _agenda, agendar, asignar, cancelar, CitaRepository, _col, _datosCupo, _desde (+8 more)

### Community 26 - "StatelessWidget"
Cohesion: 0.12
Nodes (16): _Row, _VacunaRow, _ServicioCard, _ProductoCard, _ResumenCard, _SinMascotas, _CitaCard, _EmptyState (+8 more)

### Community 27 - "repositorios_test.dart"
Cohesion: 0.12
Nodes (6): OperacionException, cita, db, main, vet1, vet2

### Community 28 - "carrito_repository.dart"
Cohesion: 0.13
Nodes (14): agregar, cambiarEstado, CarritoRepository, _col, confirmarPedido, decrementar, eliminar, _pedidoDesde (+6 more)

### Community 29 - "usuario_repository.dart"
Cohesion: 0.14
Nodes (13): actualizar, actualizarVeterinario, agregarVacuna, cambiarActivo, _col, crear, eliminarVacuna, obtener (+5 more)

### Community 30 - "mascota_model.dart"
Cohesion: 0.17
Nodes (8): actualizar, agregar, _col, eliminar, ProductoRepository, stream, streamActivos, toggleActivo

### Community 31 - "registro.dart"
Cohesion: 0.17
Nodes (11): build, _contrasena1Ctrl, createState, dispose, _formKey, _mascota, _registrar, _SectionLabel (+3 more)

### Community 32 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 33 - "db.dart"
Cohesion: 0.20
Nodes (6): Db, i, mensaje, _prueba, toString, usar

### Community 34 - "package:flutter/material.dart"
Cohesion: 0.22
Nodes (4): build, HuellitasApp, initializeApp, main

### Community 35 - "create_issues.py"
Cohesion: 0.36
Nodes (4): api(), issue(), api(), create_issue()

### Community 37 - "StatefulWidget"
Cohesion: 0.29
Nodes (6): AdminCitasPage, _AdminCitasPageState, InicioDashboard, _InicioDashboardState, FormularioRegistroPage, FormularioRegistroPage

### Community 38 - "analysis_options.yaml"
Cohesion: 0.33
Nodes (5): analyzer, exclude, include, linter, rules

## Knowledge Gaps
- **554 isolated node(s):** `HuellitasTheme`, `ink`, `inkSoft`, `arena`, `leche` (+549 more)
  These have ≤1 connection - possible missing edges. (Counts symbols only; 636 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **1 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `OperacionException` connect `repositorios_test.dart` to `db.dart`?**
  _High betweenness centrality (0.029) - this node is a cross-community bridge._
- **What connects `HuellitasTheme`, `ink`, `inkSoft` to the rest of the system?**
  _554 weakly-connected nodes found - possible missing edges._
- **Should `lib/mascota_model.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.03278688524590164 - nodes in this community are weakly interconnected._
- **Why does `CitaModel` connect `inicio.dart` to `lib/mascota_model.dart`, `citas.dart`, `veterinario_tareas.dart`, `admin_detalle.dart`, `admin_citas.dart`?**
  _High betweenness centrality (0.015) - this node is a cross-community bridge._
- **Should `tienda.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.04756871035940803 - nodes in this community are weakly interconnected._
- **Why does `VacunaModel` connect `carnet.dart` to `lib/mascota_model.dart`, `veterinario_tareas.dart`, `admin_detalle.dart`?**
  _High betweenness centrality (0.008) - this node is a cross-community bridge._
- **Should `login.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.0545876887340302 - nodes in this community are weakly interconnected._