# Graph Report - VeterinariaAPK  (2026-11-13)

## Corpus Check
- 16 files · ~9,926 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 9 file(s) not represented in the graph (top: .ttf 7, (none) 1, .lock 1)

## Summary
- 298 nodes · 326 edges · 14 communities (11 shown, 3 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `75fab85a`
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
- registro_exitoso.dart
- MascotaModel
- analysis_options.yaml
- _Mayusculas
- widget_test.dart
- registro_repository.dart

## God Nodes (most connected - your core abstractions)
1. `RegistroRepository` - 6 edges
2. `FormularioRegistroPage` - 3 edges
3. `_FormularioRegistroPageState` - 3 edges
4. `MascotaModel` - 3 edges
5. `UsuarioModel` - 3 edges
6. `_Opcion` - 3 edges
7. `_OpcionState` - 3 edges
8. `dependencies` - 3 edges
9. `dev_dependencies` - 3 edges
10. `flutter` - 3 edges

## Surprising Connections (you probably didn't know these)
- `_RepoFalso` --implements--> `RegistroRepository`  [EXTRACTED]
  test/widget_test.dart → lib/registro_repository.dart

## Import Cycles
- None detected.

## Communities (14 total, 3 thin omitted)

### Community 0 - "registro.dart"
Cohesion: 0.03
Nodes (52): _alCambiarContrasena, _anchoMaximo, _apellidoCtrl, _armarUsuario, _atras, _ayudas, _barraDeAcciones, build (+44 more)

### Community 1 - "clay.dart"
Cohesion: 0.05
Nodes (33): HuellitasApp, _AvisoError, _EtiquetaGrupo, _Dato, RegistroExitosoPage, FormularioRegistroPage, _FormularioRegistroPageState, _Requisito (+25 more)

### Community 2 - "lib/huellitas_theme.dart"
Cohesion: 0.06
Nodes (28): arena, borde, bordeCampo, cardBox, chipBox, clay, claySm, clayXl (+20 more)

### Community 3 - "lib/mascota_model.dart"
Cohesion: 0.07
Nodes (25): anios, apellido, contrasena, correo, edad, especie, mascota, MascotaModel (+17 more)

### Community 4 - "validadores.dart"
Cohesion: 0.09
Nodes (19): _alfanumerico, confirmacion, contrasena, contrasenaMinima, _correo, _digitos, documento, edad (+11 more)

### Community 5 - "pubspec.yaml"
Cohesion: 0.09
Nodes (21): dependencies, flutter, flutter_localizations, description, dev_dependencies, flutter_lints, flutter_test, environment (+13 more)

### Community 6 - "manifest.json"
Cohesion: 0.17
Nodes (11): background_color, description, display, icons, lang, name, orientation, prefer_related_applications (+3 more)

### Community 7 - "registro_exitoso.dart"
Cohesion: 0.10
Nodes (11): build, main, repository, build, detalle, icon, onContinuar, repository (+3 more)

### Community 9 - "analysis_options.yaml"
Cohesion: 0.33
Nodes (5): analyzer, exclude, include, linter, rules

### Community 11 - "widget_test.dart"
Cohesion: 0.08
Nodes (16): main, _campo, ensureVisible, enterText, _escribir, fallosPendientes, _llenarCuenta, _llenarSobreTi (+8 more)

### Community 12 - "registro_repository.dart"
Cohesion: 0.18
Nodes (8): demora, mensaje, registrar, RegistroException, RegistroRepository, RegistroSimuladoRepository, toString, _RepoFalso

## Knowledge Gaps
- **174 isolated node(s):** `HuellitasTheme`, `fontDisplay`, `fontBody`, `ink`, `inkSoft` (+169 more)
  These have ≤1 connection - possible missing edges. (Counts symbols only; 235 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **3 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `RegistroRepository` connect `registro_repository.dart` to `registro.dart`, `registro_exitoso.dart`?**
  _High betweenness centrality (0.039) - this node is a cross-community bridge._
- **What connects `HuellitasTheme`, `fontDisplay`, `fontBody` to the rest of the system?**
  _174 weakly-connected nodes found - possible missing edges._
- **Should `registro.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.03389830508474576 - nodes in this community are weakly interconnected._
- **Why does `_RepoFalso` connect `registro_repository.dart` to `widget_test.dart`?**
  _High betweenness centrality (0.006) - this node is a cross-community bridge._
- **Should `clay.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.053426248548199766 - nodes in this community are weakly interconnected._
- **Why does `_Mayusculas` connect `_Mayusculas` to `registro.dart`?**
  _High betweenness centrality (0.006) - this node is a cross-community bridge._
- **Should `lib/huellitas_theme.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.058823529411764705 - nodes in this community are weakly interconnected._