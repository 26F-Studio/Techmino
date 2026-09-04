# Repository Guidelines

## Project Overview

Techmino is a cross-platform tetromino stacking game built with Lua and LÖVE 11.5. It combines many single-player rule sets with replays/TAS, custom games, localization, configurable presentation and controls, AI players, and online rooms/battles.

## Architecture & Data Flow

- `conf.lua` configures LÖVE, platform/window behavior, enabled engine modules, and the `Techmino` save identity. `main.lua` is the application bootstrap.
- `main.lua` loads `Zframework`, which owns the LÖVE event loop and exposes global services such as `SCN`, `TASK`, `FILE`, `HTTP`, `WS`, and graphics/audio helpers. Bootstrap then loads shared game tables/functions, assets, persisted state, modes, backgrounds, and scenes.
- UI actions call `loadGame(mode, quickPlay, net)` in `parts/gameFuncs.lua`. This resolves `MODES[mode]`, populates `GAME`, and transitions through `SCN` to `game` or `net_game`.
- Player construction in `parts/player/init.lua` resolves configuration in this precedence order: `GAME.modeEnv` -> `GAME.setting` -> global `SETTING` -> `parts/player/gameEnv0.lua` defaults. It then merges the selected `parts/eventsets/` hooks and initializes randomizers/tasks.
- Input flows from `Zframework` to the current scene, then through `KEY_MAP`/virtual keys to player methods. Each frame updates scene state, players, and cooperative `TASK` coroutines; drawing delegates to players and scene widgets.
- `gameOver`/`trySave` update ranks, records, statistics, and optional compressed replay data. Online flows use JSON over HTTP/WebSocket in `parts/net.lua`, feeding room state and remote player streams.
- Modes, scenes, backgrounds, and shaders are filesystem-discovered after `FILE.isSafe` checks. Keep filenames, registry IDs, and returned module tables consistent so discovery succeeds.

## Key Directories

| Path | Purpose |
| --- | --- |
| `parts/scenes/` | UI/application states. Scene modules return callbacks plus optional declarative `widgetList`. |
| `parts/modes/` | Declarative mode definitions (`env`, scoring, comparison, ranks). |
| `parts/eventsets/` | Reusable gameplay hooks selected by `env.eventSet`. |
| `parts/player/` | Player construction, simulation, rendering, and piece sequence generators. |
| `parts/language/` | Locale tables, dictionaries, and localized manuals. |
| `parts/backgrounds/`, `parts/shaders/` | Auto-discovered visual modules and GLSL shaders. |
| `media/` | Shipped images, music, effects, samples, and voice packs. Preserve third-party attribution. |
| `Zframework/` | Bundled legacy LÖVE framework and global runtime services; modify conservatively. |
| `.github/build/` | Platform-specific packaging resources, icons, and templates. |
| `.github/actions/` | Local composite actions used by CI. |

## Development Commands

LÖVE 11.5 must be installed and available as `love`.

```sh
# Run from the repository root
love .

# Run the built-in mode-loading smoke scan
love . --test

# CI's headless form, using its downloaded AppImage and packaged artifact
xvfb-run --auto-servernum ./love.AppImage ./core.love --test
```

There is no repository-defined Makefile, dependency-install script, formatter command, or lint command. `.github/workflows/main.yml` is the authoritative build/package workflow. It packages `media/`, `parts/`, `Zframework/`, `conf.lua`, `main.lua`, `version.lua`, `legals.md`, and `license.txt` into `core.love`, then produces Android, Linux, web, and Windows artifacts. Do not invent npm/LuaRocks workflows.

For web packaging, CI uses unpinned `npx love.js`; check `.github/workflows/main.yml` before reproducing or changing that command.

## Code Conventions & Common Patterns

- Follow `.editorconfig` (EmmyLuaCodeStyle): spaces, final newline, compact calls/tables, and no spaces around operators, assignments, or commas. Preserve the repository's dense Lua style instead of reformatting surrounding code.
- Naming: camelCase for functions/locals, `_camelCase` for private helpers, uppercase for shared registries/state (`GAME`, `MODES`, `SETTING`), and mostly lowercase snake_case for mode/scene IDs (`sprint_40l`, `net_game`). Match existing filenames even where older files use camelCase.
- Modules normally return plain tables. Representative patterns: `parts/scenes/about.lua` for a scene and `parts/modes/sprint_40l.lua` for a mode. Avoid introducing class or dependency-injection frameworks.
- State management is intentionally global/data-driven. Canonical shared schemas live in `parts/gameTables.lua`; global lifecycle and persistence functions live in `parts/gameFuncs.lua`. Cache globals/library calls into locals in hot paths, as existing player/render code does.
- `TASK.new(function() ... coroutine.yield() ... end)` is the cooperative async pattern. Use existing `TEST.yieldN`, `TEST.yieldT`, task locks, and wait helpers rather than blocking the LÖVE loop.
- Persisted file operations use `pcall` and surface localized `MES.new('error', ...)` messages. Missing assets/translations use fallback values plus warnings. Use assertions for programmer invariants, not recoverable player-facing failures.
- In project convention, double-quoted strings are generally player-readable text and single-quoted strings are internal values. Except for Lua's `gcinfo`, `gc` identifiers abbreviate graphics.
- New locales require coordinated changes to `parts/language/lang_<locale>.lua`, registration in `main.lua`, and selection UI in `parts/scenes/lang.lua`. Respect fallback locale behavior.
- New modes should remain declarative and reuse `parts/eventsets/` where possible. Adding a registry entry to `parts/modes.lua` and a matching safe module filename integrates the mode with discovery and smoke QA.

## Important Files

- `conf.lua`: LÖVE 11.5 configuration, platform globals, save identity, and window/module settings.
- `main.lua`: bootstrap, global subsystem wiring, asset/locale registration, module discovery, persisted-state loading, and `--test` handling.
- `Zframework/init.lua`: custom `love.run`, event dispatch, lifecycle hooks, and runtime error capture.
- `parts/gameTables.lua`: canonical shared state/default tables.
- `parts/gameFuncs.lua`: game lifecycle, persistence, settings, ranking, and replay functions.
- `parts/scenes/game.lua`: primary local-game scene and input/update/draw flow.
- `parts/player/init.lua`, `parts/player/player.lua`: player environment composition and simulation behavior.
- `parts/modes.lua`: mode metadata, map placement, icons, and unlock graph.
- `parts/net.lua`, `parts/netPlayer.lua`: online transport, room state, and remote players.
- `version.lua`: runtime and package version metadata consumed by CI.
- `updateLog.txt`: release history; CI parses the first numeric section for release notes.
- `.editorconfig`: the only repository formatting policy.
- `.github/workflows/main.yml`: CI triggers, smoke test, packaging, release, and Pages deployment.
- `legals.md`, `license.txt`: LGPLv3 and third-party notices.

## Runtime/Tooling Preferences

- Runtime: LÖVE 11.5 (LuaJIT in normal LÖVE builds). Standalone Lua 5.3 in CI is only used to read release metadata.
- Package manager: none. There is no `package.json`, lockfile, rockspec, or vendored package-manager workflow.
- Treat `Zframework` as legacy internal infrastructure, not a reusable framework recommendation. Existing code depends on its globals and event loop.
- Build outputs belong under CI's `build/`/`release/` staging, not in source directories. Current CI packages Android, Linux, web, and Windows; macOS/iOS assets exist but have no current workflow jobs.
- Update `version.lua` and place the newest entry first in `updateLog.txt` for releases. Check `.github/actions/update-version/action.yml` carefully: its snapshot identity replacement no longer matches current `conf.lua`.

## Testing & QA

- `love . --test` is an application-level smoke scan, not a unit suite. It waits for startup, enters and exits every discovered mode except `netBattle`, watches the framework error collector, and exits 0/1.
- CI runs the packaged `core.love` under LÖVE 11.5 and Xvfb before downstream platform packaging. A passing scan proves mode initialization/scene transitions do not raise captured runtime errors; it does not prove gameplay correctness.
- There is no Busted/LuaUnit-style suite, dedicated `tests/` tree, fixture/mock system, coverage tooling, or stated coverage threshold.
- Adding a discoverable mode automatically includes it in the smoke scan. For behavior beyond loadability, exercise the changed scene/mode manually and document the scenario in the change description.
- Manual input-event QA is available through the in-app console command `test`, which opens `parts/scenes/test.lua`. This is separate from the `--test` startup flag.
- Bug reports should include a crash screenshot and reproduction steps or trigger conditions, matching `.github/ISSUE_TEMPLATE/`.
- When the goal is to verify only that a mode initializes and the in-app UI flows (scene transitions, widget rendering, draw calls), do **not** run the full `love . --test` smoke scan — it spins up every discovered mode, takes a while, and noise from unrelated mode load issues obscures the mode under test. Instead launch the game directly with `love .`, navigate to the specific scene/mode, and observe. Reserve `--test` for CI/release gating or for changes that touch discovery, scene wiring, or globally-shared widget code.
