# Graph Report - VeterinariaAPK  (2026-11-14)

## Corpus Check
- 19 files · ~11,312 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 9 file(s) not represented in the graph (top: .ttf 7, (none) 1, .lock 1)

## Summary
- 337 nodes · 388 edges · 15 communities (12 shown, 3 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `807293e6`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- registro.dart
- clay.dart
- lib/huellitas_theme.dart
- lib/mascota_model.dart
- validadores.dart
- pubspec.yaml
- manifest.json
- inicio.dart
- MascotaModel
- analysis_options.yaml
- _Mayusculas
- widget_test.dart
- registro_repository.dart
- inicio_sesion.dart

## God Nodes (most connected - your core abstractions)
1. `RegistroRepository` - 9 edges
2. `InicioSesionPage` - 3 edges
3. `_InicioSesionPageState` - 3 edges
4. `FormularioRegistroPage` - 3 edges
5. `_FormularioRegistroPageState` - 3 edges
6. `RegistroException` - 3 edges
7. `_Opcion` - 3 edges
8. `_OpcionState` - 3 edges
9. `MascotaModel` - 3 edges
10. `UsuarioModel` - 3 edges

## Surprising Connections (you probably didn't know these)
- `_RepoFalso` --implements--> `RegistroRepository`  [EXTRACTED]
  test/widget_test.dart → lib/registro_repository.dart

## Import Cycles
- None detected.

## Communities (15 total, 3 thin omitted)

### Community 0 - "registro.dart"
Cohesion: 0.04
Nodes (51): _alCambiarContrasena, _anchoMaximo, _apellidoCtrl, _armarUsuario, _atras, _ayudas, _barraDeAcciones, build (+43 more)

### Community 1 - "clay.dart"
Cohesion: 0.05
Nodes (32): _EtiquetaGrupo, _Requisito, actual, AvisoError, build, cargando, child, ClayButton (+24 more)

### Community 2 - "lib/huellitas_theme.dart"
Cohesion: 0.06
Nodes (28): arena, borde, bordeCampo, cardBox, chipBox, clay, claySm, clayXl (+20 more)

### Community 3 - "lib/mascota_model.dart"
Cohesion: 0.06
Nodes (26): anios, apellido, contrasena, correo, edad, especie, mascota, MascotaModel (+18 more)

### Community 4 - "validadores.dart"
Cohesion: 0.09
Nodes (19): _alfanumerico, confirmacion, contrasena, contrasenaMinima, _correo, _digitos, documento, edad (+11 more)

### Community 5 - "pubspec.yaml"
Cohesion: 0.09
Nodes (21): dependencies, flutter, flutter_localizations, description, dev_dependencies, flutter_lints, flutter_test, environment (+13 more)

### Community 6 - "manifest.json"
Cohesion: 0.17
Nodes (11): background_color, description, display, icons, lang, name, orientation, prefer_related_applications (+3 more)

### Community 7 - "inicio.dart"
Cohesion: 0.08
Nodes (19): _abrir, BienvenidaPage, build, repository, build, InicioPage, repository, usuario (+11 more)

### Community 9 - "analysis_options.yaml"
Cohesion: 0.33
Nodes (5): analyzer, exclude, include, linter, rules

### Community 11 - "widget_test.dart"
Cohesion: 0.07
Nodes (19): main, _abrirRegistro, _campo, ensureVisible, enterText, _escribir, fallosPendientes, iniciarSesion (+11 more)

### Community 12 - "registro_repository.dart"
Cohesion: 0.17
Nodes (7): _cuentas, demora, iniciarSesion, mensaje, registrar, RegistroException, toString

### Community 14 - "inicio_sesion.dart"
Cohesion: 0.08
Nodes (21): build, _contrasenaCtrl, _correoCtrl, createState, dispose, _entrar, _enviando, _error (+13 more)

## Knowledge Gaps
- **199 isolated node(s):** `repository`, `build`, `usuario`, `repository`, `build` (+194 more)
  These have ≤1 connection - possible missing edges. (Counts symbols only; 262 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **3 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `RegistroRepository` connect `inicio.dart` to `registro.dart`, `registro_repository.dart`, `inicio_sesion.dart`?**
  _High betweenness centrality (0.047) - this node is a cross-community bridge._
- **What connects `repository`, `build`, `usuario` to the rest of the system?**
  _199 weakly-connected nodes found - possible missing edges._
- **Should `registro.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.03636363636363636 - nodes in this community are weakly interconnected._
- **Why does `RegistroException` connect `registro_repository.dart` to `widget_test.dart`?**
  _High betweenness centrality (0.014) - this node is a cross-community bridge._
- **Should `clay.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.054878048780487805 - nodes in this community are weakly interconnected._
- **Should `lib/huellitas_theme.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.058823529411764705 - nodes in this community are weakly interconnected._
- **Should `lib/mascota_model.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.0625 - nodes in this community are weakly interconnected._