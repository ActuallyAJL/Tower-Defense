# Tower Defense

A browser-based Tower Defense game built with TypeScript and HTML5 Canvas. No frameworks, no bundler required — open `index.html` and play.

## Gameplay

Place towers on the map to stop waves of enemies from reaching the exit. Kill enemies to earn gold. Spend gold to buy and upgrade towers. Survive all waves to win.

- **Lives** — enemies that reach the exit cost lives. Lose them all and it's game over.
- **Gold** — earned by killing enemies; used to buy and upgrade towers.
- **Waves** — start manually or let the auto-timer count down. Each wave is harder than the last.

## Towers

| Tower | Role |
|-------|------|
| Basic | Balanced damage, medium range |
| Sniper | High damage, long range, armor-piercing |
| Slow | Applies a speed debuff to enemies in range |
| Bomb | Area-of-effect splash damage |

## Enemies

| Enemy | Notes |
|-------|-------|
| Basic | Standard speed and HP |
| Fast | Low HP, very fast |
| Tank | High HP, armored, slow |
| Swarm | Tiny HP, spawns in large groups |

## Getting Started

### Prerequisites

- Node.js ≥ 18 (for the TypeScript compiler and test runner)
- A modern browser

### Install & Run

```bash
git clone https://github.com/ActuallyAJL/Tower-Defense.git
cd Tower-Defense
npm install
npm run build
# then open index.html in your browser, or:
npx serve .
```

### Run Tests

```bash
npm test
```

## Tech Stack

- **TypeScript** — strict mode, compiled to ES modules
- **HTML5 Canvas 2D** — all rendering
- **Vitest** — unit tests for game logic

## Project Structure

```
src/          TypeScript source
assets/       Sprites and art
tests/        Vitest unit tests
index.html    Game host page
CLAUDE.md     AI collaboration guide
```

## Contributing

This repo is open to contributions via Pull Request. Direct pushes to `main` are disabled — all changes require a PR with at least one review.

1. Fork the repo
2. Create a branch: `feat/your-feature` or `fix/your-bug`
3. Open a PR against `main`

Please follow [conventional commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `chore:`, `docs:`).

## License

MIT
