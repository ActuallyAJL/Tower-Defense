# Tower Defense — CLAUDE.md

This file is the primary reference for Claude when working on this project.

## Project Overview

A browser-based Tower Defense game built with vanilla TypeScript and HTML5 Canvas. The player places towers on a map to stop waves of enemies from reaching the end of the path. Enemies that reach the end cost the player lives; earning gold from kills allows purchasing and upgrading towers.

## Tech Stack

- **Language**: TypeScript (compiled to ES modules, no bundler required in dev)
- **Renderer**: HTML5 Canvas 2D API
- **Runtime**: Browser (no server required — open `index.html` directly or via a local static server)
- **Tests**: Vitest (unit tests for game logic; no DOM/canvas mocking needed for pure logic)
- **Build**: `tsc` only — no Webpack/Vite in initial scope

## Repository Layout

```
Tower_Defense/
├── src/
│   ├── main.ts          # Entry point — initializes canvas and game loop
│   ├── game.ts          # Top-level Game class, owns the loop and state machine
│   ├── map.ts           # Map/grid, path definition, tile types
│   ├── enemy.ts         # Enemy base class and variants
│   ├── tower.ts         # Tower base class and variants
│   ├── projectile.ts    # Projectile logic
│   ├── wave.ts          # Wave spawner and scheduling
│   ├── ui.ts            # HUD and placement UI
│   └── types.ts         # Shared interfaces and enums
├── assets/
│   └── sprites/         # PNG spritesheets (placeholder colored rects until art is ready)
├── tests/
│   └── *.test.ts        # Vitest unit tests
├── index.html           # Game host page
├── tsconfig.json
├── vitest.config.ts
├── CLAUDE.md            # You are here
└── README.md
```

## Game Design

### Core Loop
1. Player starts a wave manually (or auto-start after a countdown).
2. Enemies follow a fixed path from entry to exit.
3. Towers in range auto-attack enemies.
4. Killing enemies earns gold; gold buys/upgrades towers.
5. Surviving all waves = win; losing all lives = game over.

### Towers (initial set)
| Tower | Damage | Range | Fire Rate | Special |
|-------|--------|-------|-----------|---------|
| Basic | Low | Medium | Fast | — |
| Sniper | High | Long | Slow | Armor pierce |
| Slow | Low | Small | Medium | Applies slow debuff |
| Bomb | Medium | Medium | Slow | AoE splash |

### Enemies (initial set)
| Enemy | HP | Speed | Armor | Special |
|-------|-----|-------|-------|---------|
| Basic | Low | Medium | No | — |
| Fast | Low | High | No | — |
| Tank | High | Slow | Yes | Armor reduces damage |
| Swarm | Tiny | High | No | Spawns in large groups |

### Map
- Grid-based (e.g., 20×14 tiles).
- Path is pre-defined per level (no maze building in v1).
- Towers can only be placed on non-path, non-blocked tiles.

## Development Guidelines

- **No global mutable state** outside of the `Game` class.
- **Game loop**: `requestAnimationFrame`-based with a fixed-timestep update (`dt` capped at 100 ms to avoid spiral of death on tab blur).
- **Entity IDs**: assign a monotonic integer `id` to every enemy, tower, and projectile at creation. Never reuse IDs in a session.
- **Separation of concerns**: rendering logic lives in `render()` methods; game logic lives in `update(dt)`. Never query the DOM inside game logic.
- **TypeScript strictness**: `strict: true` in `tsconfig.json`. No `any` unless wrapping a third-party API.
- **No premature abstraction**: add a base class only when there are two concrete subclasses that share real behavior.
- **Tests**: write unit tests for any non-trivial pure function (damage calculation, path-finding, wave scheduling). Skip tests for rendering code.

## Running Locally

```bash
npm install        # install devDependencies (typescript, vitest)
npm run build      # tsc — outputs to dist/
npm run test       # vitest run
# open index.html in browser, or:
npx serve .        # simple static server
```

## Contribution Rules

- All changes go through a Pull Request; direct pushes to `main` are blocked.
- PRs require at least one approving review before merge.
- Branch naming: `feat/<short-desc>`, `fix/<short-desc>`, `chore/<short-desc>`.
- Commit style: conventional commits (`feat:`, `fix:`, `chore:`, `docs:`).
