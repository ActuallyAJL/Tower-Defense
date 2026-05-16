# Tower Defense — CLAUDE.md

This file is the primary reference for Claude when working on this project.
Read it fully before writing any code.

---

## Project Goal

Build a **complete, polished tower defense game** with **procedurally generated content**.
Every feature a player expects from the genre must eventually be present. Procedural
generation is a first-class concern — the available towers, enemy variants, map layout,
elemental affinities, and wave compositions are all generated from a single seed each run
so no two playthroughs are identical.

Target platforms: Windows, macOS, Linux, Steam / Steam Deck, iOS, Android.

---

## Tech Stack

- **Engine**: Godot 4.6 (the installed version — do not use deprecated APIs)
- **Language**: GDScript only; no C#
- **IDE**: VSCode (`godot-tools` extension) for scripts; Godot Editor for scenes and inspector
- **VCS**: Git — all changes via PR against `main`; direct pushes blocked; 1 review required

### Developer note

The developer has a **C# background** and is learning GDScript. Bridge explanations using
C# analogues where helpful:

| C# | GDScript |
| --- | --- |
| `class Foo : Node` | `extends Node` + `class_name Foo` |
| Events / delegates | `signal` + `.connect()` |
| Properties / getters | `@export var` / `set(v):` |
| `List<T>` / `Dictionary<K,V>` | `Array[T]` / `Dictionary` |
| `null` check | `== null` or `if not node:` |
| `async` / `await` | `await` + Godot signal or coroutine |
| Interfaces | Duck typing or shared base node |

---

## Current File Layout

```text
Tower_Defense/
├── project.godot              # Godot 4.6 project config; autoloads registered here
├── scenes/
│   └── main.tscn              # Single scene: Node2D root with main.gd attached
├── scripts/
│   ├── main.gd                # Grid, map drawing, tower placement input, wires everything
│   ├── autoloads/
│   │   ├── run_seed.gd        # Singleton: seeded RNG for the current run
│   │   └── game_state.gd      # Singleton: lives, gold, wave; emits game signals
│   ├── game/
│   │   ├── enemy.gd           # Enemy node: follows waypoints, takes damage, HP bar
│   │   ├── tower.gd           # Tower node: targets enemies, fires projectiles
│   │   ├── projectile.gd      # Homing projectile: AoE, slow, pierce-armor support
│   │   └── wave_manager.gd    # Spawns enemies from 8 hardcoded wave definitions
│   ├── map/
│   │   └── path_generator.gd  # Static util: generates a left-to-right winding path
│   └── ui/
│       └── hud.gd             # CanvasLayer HUD: top bar, tower shop, overlay panels
├── resources/
│   ├── enemy_data.gd          # EnemyData Resource + static factory (4 hardcoded types)
│   └── tower_data.gd          # TowerData Resource + static factory (4 hardcoded types)
└── assets/
    ├── sprites/               # Placeholder — no art yet; everything drawn with primitives
    ├── fonts/
    └── audio/
```

---

## What Is Already Working

| System | Status |
| --- | --- |
| 20×12 grid map with procedural winding path | ✅ |
| `RunSeed` autoload (seeded, deterministic RNG) | ✅ |
| `GameState` autoload (lives, gold, wave + signals) | ✅ |
| `PathGenerator` static util | ✅ |
| Enemy node: 4 types, waypoint following, armor, slow effect, HP bar | ✅ |
| Tower node: 4 types, targeting, barrel rotation, range indicator | ✅ |
| Projectile: homing, AoE splash, slow application, pierce-armor | ✅ |
| WaveManager: 8 hardcoded waves, spawn queue, alive tracking | ✅ |
| HUD: lives / wave / gold labels, tower shop, start-wave button, game-over/win overlay | ✅ |
| Interactive tower placement (left-click place, right-click deselect, hover highlight) | ✅ |
| Entry / exit portal pulse animation | ✅ |

---

## Feature Roadmap — Everything Still To Build

This is the target feature set. Implement features in whatever order makes sense given
the current state; prefer features that unblock other features first.

### Core Tower Defense Features

- **Tower upgrades** — spend gold to level up a placed tower (2–3 tiers; each tier
  improves damage, range, or fire rate; show upgrade button when a tower is selected)
- **Tower selling** — right-click a placed tower to sell it for a partial refund (~60%)
- **Tower selection / info panel** — clicking a placed tower shows its current stats,
  upgrade cost, and a sell button in the HUD
- **Range preview on hover** — when a tower type is selected in the shop, show its range
  circle on the hovered tile before placing
- **Game speed controls** — pause (Space), normal (1×), fast-forward (2×) buttons in HUD
- **Between-wave prep time** — short countdown (e.g. 10 s) between waves; player can still
  place towers; "Start Early" button skips remaining countdown
- **Boss enemies** — a tougher enemy variant that appears every 2–3 waves; large, high HP,
  special visual (crown/glow); rewards extra gold
- **Floating damage numbers** — small number pops up at hit location and fades out; color
  codes: white = normal, yellow = crit/pierce, grey = absorbed by armor
- **Enemy HP scaling** — each wave increases base enemy HP by a percentage so later waves
  stay challenging regardless of tower upgrades
- **Score / points system** — points per kill (scaled by enemy type and wave); show on HUD
  and result screen
- **Lives-loss visual feedback** — screen flash + brief camera shake when a life is lost
- **Wave preview panel** — before pressing Start Wave, show icons of what enemy types are
  coming in the next wave

### Procedural Generation (core design pillar — high priority)

These features turn a standard TD into a roguelite where every run plays differently.
All generators must read from `RunSeed.rng` so runs are reproducible by seed.

- **Elemental system** — at run start, draw 3–5 elements from a pool (e.g. Fire, Ice,
  Storm, Void, Earth, Light). Each element has: a name, a color, a damage-type tag, a
  debuff effect (Burn DoT / Freeze slow / Stun / Armor shred / Root / Heal aura),
  and a synergy bonus when two same-element towers are placed adjacent.
  Store in `ElementData` resource; generate via `scripts/procedural/element_gen.gd`.

- **Procedurally generated tower roster** — instead of 4 fixed tower types, generate
  6–8 towers per run. Each tower = base archetype (Shooter / Slow / AoE / Support) ×
  assigned element × stat rolls within archetype ranges. Give each a procedural name
  (e.g. "Frost Cannon", "Void Pulse"). Store in `TowerData`; generate via
  `scripts/procedural/tower_gen.gd`. Replace the hardcoded `TowerData.create()` factory.

- **Procedurally generated enemy variants** — base archetypes (Basic / Fast / Tank / Swarm)
  get element assignments per run, giving them resistances and weaknesses that interact with
  the tower roster. Generate via `scripts/procedural/enemy_gen.gd`.

- **Procedurally generated wave compositions** — wave count, enemy mix, and scaling curves
  generated from the seed. Replace the hardcoded `WAVES` array in `wave_manager.gd`.
  Generate via `scripts/procedural/wave_gen.gd`.

- **Seed display and sharing** — show the current run seed on the HUD (small, top-center or
  corner). On the result screen (win/loss), display it prominently so players can share runs.
  Allow seed input on the main menu to replay a specific run.

- **Run modifiers** — optionally roll 1–2 global modifiers per run (e.g. "Enemies move 20%
  faster", "AoE towers deal double splash", "Gold rewards are halved but lives are 30").
  Show active modifiers in the HUD.

- **Map variety** — extend `PathGenerator` with multiple algorithm variants (S-curve,
  spiral, branching sub-paths) and select the variant per run from the seed.

### UI / UX

- **Main menu scene** — title, New Run button, Seed input field, Settings
- **Settings** — master volume, SFX volume, music volume, fullscreen toggle
- **Hotkeys** — number keys 1–4 select tower types; Escape deselects; Space pause
- **Tooltip system** — hover a tower in the shop to see full stats before buying
- **Enemy info on hover** — hover a live enemy to see its name, current HP, armor, element

### Polish & Feel

- **Sound effects** — tower fire, enemy hit, enemy death, enemy exits, life lost, wave
  start, wave clear, game over, button clicks
- **Background music** — looping ambient track (placeholder OK until assets arrive)
- **Particle effects** — small burst on enemy death; impact spark on hit; use
  `GPUParticles2D` or manual `_draw()` circle burst
- **Screen shake** — on life lost and on boss death; use `Camera2D` offset with tween
- **Smooth tile shading** — path tiles get a worn/dirt texture feel using additional
  draw passes; grass tiles get slight variation
- **Enemy direction indicator** — small arrow above enemy pointing toward next waypoint

---

## Key Systems — How They Connect

```text
RunSeed (autoload)
  └─ seeds PathGenerator, element_gen, tower_gen, enemy_gen, wave_gen

GameState (autoload)
  ├─ emits: lives_changed, gold_changed, wave_changed, game_over, game_won
  └─ consumed by: HUD (labels), enemy.gd (lose_life), tower placement (spend_gold)

main.gd
  ├─ owns: _entities (Node2D parent for all in-world nodes)
  ├─ owns: WaveManager (spawns enemies into _entities)
  ├─ owns: HUD (CanvasLayer)
  └─ handles: mouse input → tower placement

WaveManager
  ├─ reads: waypoints + entities_parent from main.gd
  ├─ spawns: Enemy nodes into entities_parent
  └─ emits: wave_completed, all_waves_completed

Enemy (Node2D)
  ├─ reads stats from: EnemyData resource
  ├─ calls: GameState.earn_gold() on death, GameState.lose_life() on exit
  └─ exposes: take_damage(amount, pierce_armor), apply_slow(factor, duration)

Tower (Node2D)
  ├─ reads stats from: TowerData resource
  ├─ spawns: Projectile into get_parent() (_entities)
  └─ reads: enemies_parent to scan for targets

Projectile (Node2D)
  ├─ on impact: calls enemy.take_damage(), enemy.apply_slow() if applicable
  └─ AoE: iterates get_parent().get_children() for nearby enemies
```

---

## Seeded RNG Pattern

All procedural systems must use `RunSeed.rng` — never bare `randf()` — so that the same
seed always produces the same run.

```gdscript
# In any generator:
var value := RunSeed.rng.randf_range(0.0, 1.0)
var index := RunSeed.rng.randi_range(0, pool.size() - 1)
```

Generator scripts live in `scripts/procedural/` and are pure functions: they take
configuration params and the RNG, return data, and have no side effects.

---

## GDScript Conventions

- `class_name` on every script referenced by other scripts
- Signals over direct method calls for cross-node communication
- `extends Resource` for pure data objects (`EnemyData`, `TowerData`, `ElementData`)
- Autoloads only for truly global singletons (`RunSeed`, `GameState`)
- Type hints on all variables and function signatures
- `@onready var foo: Bar = $Path/Foo` instead of `get_node()` strings
- `snake_case` for variables/functions; `PascalCase` for class names
- No magic numbers — define named constants at top of each script
- No `any` typing unless wrapping an untyped external API

---

## Development Guidelines

- **Scene ownership**: a scene manages its own children; communicate upward via signals only
- **Data vs. logic**: `*_data.gd` Resources contain no Node references; all behavior is in node scripts
- **Generator isolation**: generator functions take an `rng: RandomNumberGenerator` argument,
  return data, and produce no side effects — this makes them testable and seed-reproducible
- **No premature abstraction**: add a base class only when two concrete subclasses share real behavior
- **Commits**: conventional commits (`feat:`, `fix:`, `chore:`, `docs:`); PRs only; 1 review required

---

## Running the Project

1. Open Godot 4.6 → **Import** → select this folder
2. Press **F5** to run
3. To edit scripts in VSCode: **Editor → Editor Settings → Text Editor → External → Use External Editor**
4. If `GameState` or `RunSeed` are undefined after editing `project.godot`, close and reopen the project in Godot to re-register autoloads

## Export Targets (future)

- Windows Desktop
- macOS
- Linux / Steam / Steam Deck
- Android
- iOS
