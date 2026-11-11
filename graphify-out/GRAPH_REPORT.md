# Graph Report - VeterinariaAPK  (2026-11-11)

## Corpus Check
- 14 files · ~4,145 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 2 file(s) not represented in the graph (top: (none) 1, .lock 1)

## Summary
- 155 nodes · 160 edges · 12 communities (9 shown, 3 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `7c1eb6aa`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- lib/registro.dart
- huellitas_theme.dart
- lib/huellitas_theme.dart
- lib/mascota_model.dart
- mascota_model.dart
- pubspec.yaml
- manifest.json
- main.dart
- MascotaModel
- analysis_options.yaml
- _FormularioRegistroPageState
- widget_test.dart

## God Nodes (most connected - your core abstractions)
1. `MascotaModel` - 3 edges
2. `UsuarioModel` - 3 edges
3. `_FormularioRegistroPageState` - 3 edges
4. `dev_dependencies` - 3 edges
5. `_FormularioRegistroPageState` - 3 edges
6. `analyzer` - 2 edges
7. `linter` - 2 edges
8. `HuellitasApp` - 2 edges
9. `FormularioRegistroPage` - 2 edges
10. `_SectionLabel` - 2 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Import Cycles
- None detected.

## Communities (12 total, 3 thin omitted)

### Community 0 - "lib/registro.dart"
Cohesion: 0.08
Nodes (22): build, _contrasena1Ctrl, createState, dispose, _formKey, FormularioRegistroPage, _mascota, _registrar (+14 more)

### Community 1 - "huellitas_theme.dart"
Cohesion: 0.11
Nodes (16): arena, cardBox, chipBox, clay, claySm, clayXl, coral, field (+8 more)

### Community 2 - "lib/huellitas_theme.dart"
Cohesion: 0.11
Nodes (16): arena, cardBox, chipBox, clay, claySm, clayXl, coral, field (+8 more)

### Community 3 - "lib/mascota_model.dart"
Cohesion: 0.12
Nodes (15): apellido, contrasena, correo, edad, mascota, MascotaModel, nombre, numeroDocumento (+7 more)

### Community 4 - "mascota_model.dart"
Cohesion: 0.12
Nodes (15): apellido, contrasena, correo, edad, mascota, MascotaModel, nombre, numeroDocumento (+7 more)

### Community 5 - "pubspec.yaml"
Cohesion: 0.13
Nodes (14): dependencies, flutter, description, dev_dependencies, flutter_lints, flutter_test, environment, sdk (+6 more)

### Community 6 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 7 - "main.dart"
Cohesion: 0.22
Nodes (5): build, HuellitasApp, main, _SectionLabel, _SectionLabel

### Community 9 - "analysis_options.yaml"
Cohesion: 0.33
Nodes (5): analyzer, exclude, include, linter, rules

## Knowledge Gaps
- **85 isolated node(s):** `HuellitasTheme`, `ink`, `inkSoft`, `arena`, `leche` (+80 more)
  These have ≤1 connection - possible missing edges. (Counts symbols only; 113 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **3 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `_FormularioRegistroPageState` connect `_FormularioRegistroPageState` to `lib/registro.dart`?**
  _High betweenness centrality (0.007) - this node is a cross-community bridge._
- **What connects `HuellitasTheme`, `ink`, `inkSoft` to the rest of the system?**
  _85 weakly-connected nodes found - possible missing edges._
- **Should `lib/registro.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.07936507936507936 - nodes in this community are weakly interconnected._
- **Why does `_FormularioRegistroPageState` connect `_FormularioRegistroPageState` to `lib/registro.dart`?**
  _High betweenness centrality (0.007) - this node is a cross-community bridge._
- **Should `huellitas_theme.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.10526315789473684 - nodes in this community are weakly interconnected._
- **Should `lib/huellitas_theme.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.1111111111111111 - nodes in this community are weakly interconnected._
- **Should `lib/mascota_model.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.11764705882352941 - nodes in this community are weakly interconnected._