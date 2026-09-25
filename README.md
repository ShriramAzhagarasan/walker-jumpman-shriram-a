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

**Controls:** A/D or arrow keys to move · Space to jump · Space again mid-air to web-zip (double jump) · R to retry · Esc or P to pause · Enter to start/resume

### Latest update — villains, skyscrapers, web-zip, traffic

- **Characters redrawn:** Spider-Man (outlined, animated run/jump/idle poses, angled eye lenses, chest spider), Vulture (feathered green wings, white ruff), Green Goblin (purple hat and tunic, bat glider, pumpkin bomb), Doctor Octopus (trench coat, goggles, four segmented claw tentacles). Villains now animate every frame (`features/villains/villains.gd`).
- **Web-zip double jump:** one extra jump in the air. The web line shoots from Spider-Man's wrist all the way to the ceiling of the play area.
- **Skyscrapers:** three tall towers (x=784, 1328, 1860) that are 60–74 px above their neighbours, which one 53 px jump can't reach. You have to web-zip.
- **Moving taxis:** four cabs patrol rooftops, some over short ranges and some over long ones, alongside the two parked cabs. Traffic is timed off the attempt clock, so every retry replays it the same way.
- **Death messages:** "Watch the taxis! You landed on a cab full of civilians." / "Missed the landing: straight down onto the civilians below."
- **Scenery:** the sky fades smoothly between zones, every rooftop is a full building down to the street, and there's a new moon.

---

## Changes from starter

### Character — Spider-Man

Replaced the starter's ink/blue "Jumpman" character with a geometric Spider-Man:
- Red (`#CE1620`) circular head and chest; blue (`#003790`) arms and legs
- White elongated eye lens polygons — the primary identifying feature, facing-aware (front eye is larger)
- Spider cross symbol on chest (two overlapping black rectangles)
- Black shoulder seam separating head from torso
- Stride animation preserved from starter
- Collision shape and movement parameters **unchanged**

### Level — Manhattan Rooftops (Zone 3)

Three new elevated platforms appended beyond the original route (level width 960 → 1600):

| Platform | x | top-y | gap from previous |
|----------|---|-------|-------------------|
| Rooftop 1 | 1000–1128 | 288 | 40 px (requires jump) |
| Rooftop 2 | 1160–1280 | 272 | 32 px + spike hazard |
| Rooftop 3 | 1328–1472 | 288 | 48 px |

New spike hazard at x=1108–1132 on Rooftop 1's right edge — player must jump before the spikes and clear the gap in one movement.

Finish relocated from x=916 to x=1432 (Rooftop 3). Player must complete Zone 3 to win.

City building silhouettes drawn in the background behind Zone 3.

### Supporting code changes

| File | Change |
|------|--------|
| `player.gd` | `_draw()` replaced with Spider-Man character |
| `first_steps.json` | Level width 1600, 3 new platforms, new hazard, finish relocated |
| `session.gd` | Background extended; grid extends to `level.width`; hazard and finish drawing use entry y-coords (not hard-coded 320) |
| `hud.gd` | Title, subtitle, progress bar range, menu text updated |
| `route_driver.gd` | 3 new jump marks added (945, 1070, 1260) |
| `test_game.gd` | Route tick limit raised 900→1500 for longer level |

---

## Known limitations

- Jump marks for the automated test route were derived from physics math; empirical Godot verification pending.
- No audio (same as starter).
- Git setup requires Xcode CLI tools fix before pushing to GitHub.
- Film link: [to be added after recording]
- Film SHA-256: [to be added]

---

## Final film

URL: [to be added]
Filename: [to be added]
SHA-256: [to be added]
Game revision shown in film: [commit SHA]

---

## Documents

- [CHANGE-BRIEF.md](CHANGE-BRIEF.md) — predictions written before implementation
- [TEST-REPORT.md](TEST-REPORT.md) — verification evidence
- [FRICTIONAL.md](FRICTIONAL.md) — honest log of what worked and what didn't
- [SOURCES.md](SOURCES.md) — starter credit, asset provenance, AI contributions
