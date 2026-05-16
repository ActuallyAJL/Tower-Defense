# Tower Defense — CLAUDE.md

This file is the primary reference for Claude when working on this project.

## Project Overview

A **procedurally generated** browser-and-desktop Tower Defense game built with **Godot 4 + GDScript**.
Every match generates a unique combination of map layout, available tower types, elemental affinities, enemy compositions, and wave structure — no two runs play the same way.

Target platforms: Windows, macOS, Linux, iOS, Android, Steam / Steam Deck.

## Tech Stack

- **Engine**: Godot 4.x (latest stable)
- **Language**: GDScript (primary); no C# in this project
- **IDE**: VSCode with the `godot-tools` extension for script editing; Godot Editor for scenes, tilemaps, inspector
- **Version control**: Git — all changes via PR, direct pushes to `main` blocked

## Developer Context

The developer is experienced in **C#**. When explaining GDScript patterns, bridge from C# equivalents:

| C# concept | GDScript equivalent |
| --- | --- |
| `class Foo : Node` | `extends Node` + optional `class_name Foo` |
| Properties / getters | `@export var` / custom setters `set(v):` |
| Events / delegates | Signals (`signal`, `emit_signal`, `connect`) |
| Interfaces | Duck typing or shared base node |
| `List<T>` / `Dictionary<K,V>` | `Array[T]` / `Dictionary` |
| `null` checks | `== null` or `if not node:` |
| `async` / `await` | `await` + Godot signals or coroutines |

## Repository Layout

```text
Tower_Defense/
├── project.godot              # Godot project config (checked in)
├── export_presets.cfg         # Platform export targets
├── scenes/
│   ├── main.tscn              # Boot scene
│   ├── game/
│   │   ├── game.tscn          # Top-level game scene
│   │   ├── map/
│   │   │   └── map.tscn       # TileMap + path overlay
│   │   ├── towers/
│   │   │   └── tower_base.tscn
│   │   └── enemies/
│   │       └── enemy_base.tscn
│   └── ui/
│       ├── hud.tscn
│       └── tower_shop.tscn
├── scripts/
│   ├── game/
│   │   ├── game.gd            # Top-level game state machine
│   │   └── wave_manager.gd    # Wave spawning and scheduling
│   ├── map/
│   │   ├── map.gd             # TileMap logic, tile queries
│   │   └── path_generator.gd  # Procedural path carving
│   ├── towers/
│   │   ├── tower_base.gd      # Base tower node
│   │   ├── tower_data.gd      # Resource: stats + element
│   │   └── tower_factory.gd   # Builds procedural TowerData
│   ├── enemies/
│   │   ├── enemy_base.gd      # Base enemy node
│   │   ├── enemy_data.gd      # Resource: stats + resistances
│   │   └── enemy_factory.gd   # Builds procedural EnemyData
│   ├── procedural/
│   │   ├── run_seed.gd        # Autoload: stores seed, exposes RNG
│   │   ├── element_gen.gd     # Generates element set for the run
│   │   ├── tower_gen.gd       # Generates tower roster for the run
│   │   ├── map_gen.gd         # Generates map + path for the run
│   │   └── wave_gen.gd        # Generates wave compositions
│   └── ui/
│       ├── hud.gd
│       └── tower_shop.gd
├── resources/
│   ├── tower_data.gd          # TowerData Resource class
│   ├── enemy_data.gd          # EnemyData Resource class
│   └── element_data.gd        # ElementData Resource class
├── assets/
│   ├── sprites/               # PNG spritesheets; placeholder rects until art is ready
│   ├── fonts/
│   └── audio/
├── addons/                    # Godot plugins (if any)
├── CLAUDE.md
└── README.md
```

## Core Design: Procedural Generation

Every match is driven by a single **integer seed** stored in the `RunSeed` autoload. All procedural systems read from this seed via a shared `RandomNumberGenerator` instance so runs are **deterministic and reproducible** (same seed → same run).

### What Gets Generated Each Run

| System | What changes |
| --- | --- |
| **Elements** | 3–5 elements drawn from a pool (e.g. Fire, Ice, Storm, Void, Earth, Light). Each element has stat modifiers and a unique debuff. |
| **Tower roster** | 6–8 towers offered in the shop. Each tower is built from: a base archetype (Shooter, Slow, AoE, Support) × a randomly assigned element × procedurally rolled stats (damage, range, fire rate, cost). |
| **Map** | Grid carved via a random-walk or BSP algorithm; path from entry to exit guaranteed; open tiles available for tower placement. |
| **Enemies** | Enemy types generated from base archetypes (Basic, Fast, Tank, Swarm) + element resistances/weaknesses assigned per run. |
| **Waves** | Count, enemy mix, and scaling curves generated from the seed. |

### Element System

Elements define the "meta" of each run. A generated element has:

- **Name** and **color** (procedurally assigned or drawn from a name pool)
- **Damage type** (used for resistance/weakness lookups)
- **Debuff** (e.g. Slow, Burn DoT, Stun, Armor shred)
- **Tower synergy bonus** when two same-element towers are placed adjacent

### Tower Generation

A tower is a `TowerData` resource with fields:

- `archetype`: enum (Shooter / Slow / AoE / Support)
- `element`: reference to a generated `ElementData`
- `damage`, `range`, `fire_rate`, `splash_radius`, `cost`: floats rolled within archetype-specific ranges
- `upgrade_path`: array of stat deltas generated per tower

### Seeded RNG Pattern

```gdscript
# Autoload: RunSeed
var seed: int
var rng := RandomNumberGenerator.new()

func start_run(s: int) -> void:
    seed = s
    rng.seed = s

func randf_range(lo: float, hi: float) -> float:
    return rng.randf_range(lo, hi)
```

All generator scripts call `RunSeed.randf_range(...)` — never `randf()` directly — so output is deterministic.

## GDScript Conventions

- **`class_name`** on every script that is referenced by other scripts.
- **Signals** over direct method calls for loose coupling between nodes (enemy died, tower placed, wave started, etc.).
- **Resources** (`extends Resource`) for pure data (TowerData, EnemyData, ElementData) — keeps data separate from node logic.
- **Autoloads** (project singletons) only for truly global state: `RunSeed`, `GameEvents` (a signal bus).
- **`@export`** for any value that should be tunable without code changes.
- **Type hints everywhere**: `var speed: float`, `func take_damage(amount: float) -> void:`.
- **No `get_node` strings** in logic code — use `@onready var foo: Bar = $Path/To/Foo` at the top of each script.
- **Snake_case** for variables and functions; **PascalCase** for class names and signals that act as types.

## Game Loop

1. Main menu → player starts a new run (random seed) or enters a specific seed.
2. `RunSeed` initialized → all generators run → map, towers, enemies, waves produced.
3. Player places towers during a prep phase, then starts the first wave.
4. Enemies follow the generated path; towers auto-attack.
5. Gold from kills → buy/upgrade towers from the procedural shop.
6. Survive all waves = win; lose all lives = game over. Seed shown on result screen for sharing.

## Development Guidelines

- **Scene ownership**: a scene is responsible for its own children. Never reach up to a parent node; use signals instead.
- **Data vs. logic**: `*_data.gd` files are pure Resources with no Node references. Logic lives in `*_base.gd` nodes.
- **No magic numbers**: define constants at the top of each script or in a shared `const.gd` autoload.
- **Generator isolation**: each generator (`map_gen.gd`, `tower_gen.gd`, etc.) takes a `RandomNumberGenerator` argument and returns data — no side effects, easy to unit-test.
- **Commits**: conventional commits (`feat:`, `fix:`, `chore:`, `docs:`). All changes via PR; 1 approving review required.

## Running the Project

1. Install [Godot 4](https://godotengine.org/download/) (latest stable).
2. Install the `godot-tools` VSCode extension.
3. Open this folder in the Godot Editor (`Import Project`).
4. Set VSCode as the external editor: **Editor → Editor Settings → Text Editor → External → Use External Editor**.
5. Press **F5** in Godot to run, or edit scripts in VSCode and switch back to Godot to test.

## Export Targets

Configured in `export_presets.cfg`:

- Windows Desktop
- macOS
- Linux / Steam
- Android
- iOS
