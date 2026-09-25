# walker-jumpman-shriram-a — Rooftop Rush

**Assignment 1 extension · CSYE 7270 Fall 2026 · Godot 4.7.2 / GDScript**
**Student:** Shriram Alagarasan · azhagarasan.s@northeastern.edu

---

## Starter credit

Based on [nikbearbrown/walker-jumpman](https://github.com/nikbearbrown/walker-jumpman) by Nik Bear Brown.
Engine: Godot 4.7.2.stable.official. No .NET runtime or external assets required.

---

## Run instructions

1. Download [Godot 4.7.2](https://godotengine.org/download) and install it in `/Applications/Godot.app` (macOS).
2. Clone or download this repository.
3. Open Godot → **Import** → select `godot/project.godot`.
4. Press **F5** (or the Play button) to run.

Alternatively, double-click `walker-jumpman.command` on macOS if Godot is installed in Applications.

**Controls:** A/D or arrow keys to move · Space to jump · Space again mid-air to web-zip (double jump) · R to retry · Esc or P to pause · Enter (or click) to start/resume/replay · M for the main menu (from pause or completion)

**Tests:** `godot --headless --path godot -s res://tests/test_game.gd` (29 checks) and `-s res://tests/test_keyboard.gd` (9 checks); all pass. See [TEST-REPORT.md](TEST-REPORT.md).

---

## Changes from starter

### Character — Spider-Man (`godot/features/player/player.gd`)

The starter's ink/blue Jumpman is replaced by a procedural Spider-Man, drawn in `_draw()` from primitives (no sprites):
- Red mask with web lines and big angled white eyes (three-quarter view), red chest with a black spider, blue flanks and legs, red boots and gloves; dark ink outline on every part
- Capsule limbs with animated **run** (stride + arm swing), **jump** (knees tucked, far arm firing the web), **fall** and **idle** poses
- Mirrors left/right with one transform (`draw_set_transform(…, Vector2(facing, 1))`)
- **Collider unchanged:** `RectangleShape2D(18, 28)` at `(0, -14)`

### Level — Rooftop Rush (`godot/levels/first_steps.json`, `godot/game/session.gd`)

Width 960 → **2,500 px** across three zones, with the finish moved from x=916 to **x=2388**:

| Zone | x range | Time of day | Key challenges |
|---|---|---|---|
| Queens | 0–512 | morning | the starter's step, gap and first hazard (now a parked taxi), kept playable |
| Midtown | 512–1000 | afternoon | a block, a moving taxi, then the **glass tower** (x=784, roof 74 px up), which needs the web-zip |
| Manhattan | 1000–2500 | night | parked taxi, **tower two** (x=1328), roofs with moving taxis, **tower three** (x=1860), the flag |

- New landings: 3 skyscrapers + 8 rooftops beyond the starter route. The starter's last roof (x 784–960) became the glass tower plus a short roof.
- Hazards: spikes → **2 parked + 4 moving taxis** (short and long patrols, timed off the attempt clock). The collision uses the cab's outline.
- Deaths name the cause: "Watch the taxis! You landed on a cab full of civilians." / "Missed the landing: straight down onto the civilians below."
- Every rooftop is drawn as a full building. The sky blends between zones. Animated background villains (Vulture, Green Goblin, Doctor Octopus in `godot/features/villains/villains.gd`) are decorative, with no collision.

### Movement: one justified addition (`godot/features/player/tuning.gd`)

The existing values are unchanged (speed, acceleration, jump −320, gravity 960, coyote 6, buffer 6).
New: `air_jumps = 1`, `air_jump_velocity = -320`. This is a **web-zip** second jump, requested so skyscrapers are reachable only with it (53 px single jump vs 60–74 px towers).
The justification and tests are in [CHANGE-BRIEF.md](CHANGE-BRIEF.md) (revision 2).

### Supporting code changes

| File | Change |
|---|---|
| `features/player/player.gd` | Spider-Man drawing; web-zip; web line anchored to the play-area ceiling |
| `features/player/tuning.gd` | `air_jumps`, `air_jump_velocity` added |
| `features/villains/villains.gd` | **new**: animated Vulture, Goblin, Doc Ock |
| `game/session.gd` | Zone backgrounds, skyscrapers, taxi hazards (parked + moving), death reasons |
| `ui/hud.gd` | Zone banner, death detail line, menu/controls text |
| `levels/first_steps.json` | 2,500 px level, 15 solids, taxis, finish at x=2388 |
| `tests/route_driver.gd` | New route: 14 ground jumps + 3 web-zips |
| `tests/test_game.gd` | Updated and new checks (29 total) |
| `tests/capture_art.gd` | **new**: engine-rendered character close-ups |

## Known limitations

- The moving-taxi timing has not been tested for fairness with first-time players, and one taxi's phase was tuned to the automated route.
- The web line is visual only (no swing physics). The zone banner can cover Spider-Man mid-jump.
- The completion time covers the last attempt only (starter behaviour).
- No audio (same as starter).
- The focus-loss pause is unit-tested but not shown in the film. The Brutalist type-check pre-gate was overridden for 4 documented false positives (`youtube/claude-liam-walker-jumpman-shriram-a-walkthrough/_qc/GATE-T-OVERRIDE.md`).

---

## Final film

- **File:** `claude-liam-walker-jumpman-shriram-a-walkthrough.mp4`: Brutalist godot-waikthrough, walker mode, 3840×2160, 30 fps, 3 min 57 s. Narrated by Liam (Kokoro), in for Bear.
- **SHA-256:** `95d5bce41859a049246d39290566955ad2fa322d9066f48a19203c7930f710c4`
- **Link:** [fill: course media storage URL]. The MP4 is not in GitHub.
- **Game revision shown:** commit `1cbbb850b988188bb2e28377dd897c2ff93d460b` · source snapshot `bb0f4ad453a25096bb04b84f1609338760328c0868e43e4dfbb8c09454cd61f7`
- **Sources, evidence and QC:** `youtube/claude-liam-walker-jumpman-shriram-a-walkthrough/`. Gameplay is a scripted-input engine capture, labeled on screen, not a human playtest.

---

## Documents

- [CHANGE-BRIEF.md](CHANGE-BRIEF.md) — predictions written before implementation
- [TEST-REPORT.md](TEST-REPORT.md) — verification evidence
- [FRICTIONAL.md](FRICTIONAL.md) — honest log of what worked and what didn't
- [SOURCES.md](SOURCES.md) — starter credit, asset provenance, AI contributions
