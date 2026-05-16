# Tower Defense

A **procedurally generated** tower defense game built with Godot 4 and GDScript. Every run generates a unique map, set of towers, elemental affinities, enemy compositions, and wave structure — no two matches play the same way.

## Gameplay

Place towers on a procedurally carved map to stop waves of enemies from reaching the exit.

- **Procedural elements** — each run draws 3–5 elements (e.g. Fire, Ice, Storm, Void) with unique damage types and debuffs
- **Procedural towers** — the shop offers a fresh roster of towers each run, built from random archetypes × elements × stat rolls
- **Procedural maps** — the grid layout and enemy path are generated from the run seed
- **Procedural waves** — enemy composition, count, and difficulty scaling are all generated
- **Seeded runs** — every run has a shareable seed; enter the same seed to replay an identical run

## Platforms

Windows · macOS · Linux · Steam / Steam Deck · iOS · Android

## Getting Started

### Prerequisites

- [Godot 4](https://godotengine.org/download/) (latest stable)
- VSCode with the [godot-tools](https://marketplace.visualstudio.com/items?itemName=geequlim.godot-tools) extension (for script editing)

### Run the Project

1. Clone the repo and open the folder in the Godot Editor (`Import Project`)
2. Press **F5** to run
3. Scripts can be edited in VSCode; switch back to Godot to test

```bash
git clone https://github.com/ActuallyAJL/Tower-Defense.git
```

## Tech Stack

- **Engine**: Godot 4
- **Language**: GDScript
- **IDE**: VSCode (scripts) + Godot Editor (scenes, tilemaps, inspector)

## Project Structure

```text
scenes/       Godot scene files (.tscn)
scripts/      GDScript source files (.gd)
├── game/     Game loop and wave management
├── map/      TileMap logic and procedural path generation
├── towers/   Tower nodes, data resources, and factory
├── enemies/  Enemy nodes, data resources, and factory
├── procedural/  Core generation systems (seed, elements, map, waves)
└── ui/       HUD and tower shop
resources/    Shared Resource classes (TowerData, EnemyData, ElementData)
assets/       Sprites, fonts, audio
```

## Contributing

All changes go through a Pull Request — direct pushes to `main` are disabled and require one approving review.

1. Fork the repo
2. Create a branch: `feat/your-feature` or `fix/your-bug`
3. Open a PR against `main`

Please use [conventional commits](https://www.conventionalcommits.org/): `feat:`, `fix:`, `chore:`, `docs:`.

## License

MIT
