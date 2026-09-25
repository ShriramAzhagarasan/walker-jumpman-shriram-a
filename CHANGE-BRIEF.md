# CHANGE-BRIEF — walker-jumpman-shriram-a

Written before implementation. Revisions are appended, not rewritten.

---

## 1. Character Concept

**Spider-Man** — a geometric interpretation of the Marvel character using only Godot's vector drawing primitives. No imported sprites.

Visual features distinguishing it from the starter "Jumpman":
- **Red and blue color palette** (`#CE1620` torso/head, `#003790` arms/legs) instead of dark ink/blue
- **Circular red head** (`draw_circle`) vs. the starter's rectangular head
- **White elongated eye lenses** (`draw_colored_polygon`, four-point polygon) — facing-aware: the front eye is larger when facing right, smaller when facing left
- **Spider cross symbol** on chest (two overlapping black rectangles)
- **Black shoulder seam** separating head from torso
- **Same stride animation** on legs (preserved from starter)

The collider is unchanged: `RectangleShape2D(18, 28)` at `Vector2(0, -14)`. All drawing stays within the same bounding box.

---

## 2. Level Extension — "Manhattan Rooftops" (Zone 3)

Three new elevated platforms appended beyond the original route (original width 960 → new width 1600).

| Platform | x range | y (top surface) | Notes |
|----------|---------|-----------------|-------|
| Rooftop 1 | 1000–1128 | 288 | 40 px gap from end of Zone 2; 32 px higher than floor |
| Rooftop 2 | 1160–1280 | 272 | 32 px gap from Rooftop 1; 16 px higher; spike hazard on Rooftop 1's right edge |
| Rooftop 3 | 1328–1472 | 288 | 48 px gap from Rooftop 2; 16 px lower; finish flag at x=1432 |

New hazard: `[1108, 272, 24, 16]` — three spikes on the right edge of Rooftop 1. Player must jump before x=1108 to clear them AND the gap.

Finish relocated from `[916, 264, 24, 56]` to `[1432, 232, 24, 56]` on Rooftop 3.

**Player decision Rooftop 1→2:** jump early (before spikes) and aim high to land on the raised Rooftop 2 — mistiming in either direction kills or drops you into the gap.

**Player decision Rooftop 2→3:** jump near the right edge; Rooftop 3 is slightly lower so the window is generous, but the gap is 48 px wide.

City building silhouettes drawn in the session background behind Zone 3 to reinforce the Manhattan theme.

---

## 3. What Must Remain Unchanged

- Movement parameters (`tuning.gd`): speed, acceleration, deceleration, jump_velocity, gravity, terminal_velocity, coyote_ticks, buffer_ticks — **not touched**
- Collision shape and position — **not touched**
- Controls: A/D/arrows, Space, R, Esc/P — **not touched**
- Retry, pause, and completion state machine — **not touched**
- All original platforms, hazards, and the Zone 1–2 route — **preserved intact**

---

## 4. Predicted Failure Cases

**Failure A — Eye polygons detach from head at edges**
The white eye polygons are drawn relative to the character origin. If the circular head's radius (6 px) is smaller than expected, the eyes may appear to float outside the head outline.
Check: run left and right in-game; screenshot the character at both facings. If eyes float, adjust polygon x offsets.

**Failure B — Route jump 7 undershoots Rooftop 1**
Jump mark at x=945 must carry the player from y=320 to y=288 (32 px up). Calculated horizontal travel: 87 px, landing at x=1032 (within Rooftop 1 at x=1000–1128). If tuning values differ slightly from the physics model, the player may land short of x=1000 and fall.
Check: run `complete-real-route` test; if it FAIL, inspect `jump_marks_used` in the evidence JSON and shift mark 6 (index 5) left by 10–20 px.

**Failure C — Zone 3 labels invisible (camera clipping)**
Labels "03 / ROOFTOP RUSH" are drawn at world y=255–273. The HUD occupies screen y=0–74 (top bar) and y=335–360 (bottom bar). If the camera y is wrong, the labels may be hidden behind the HUD.
Check: visually confirm labels appear when camera enters Zone 3. Camera y is fixed at 180, so world y=255 maps to screen y=75 — just below the HUD top. Should be fine, but must verify.

---

## Revisions

*(Add here rather than rewriting predictions above.)*

- 2026-09-24: Initial brief written before any code changes.
- 2026-09-24 (revision 2, requested by Shriram after reviewing screenshots): **departure from "movement tuning not touched".**
  `tuning.gd` gains two *new* values, `air_jumps = 1` and `air_jump_velocity = -320.0`, for a web-zip double jump.
  All existing values (speed, acceleration, deceleration, `jump_velocity`, gravity, terminal velocity, coyote 6, buffer 6) are unchanged, and so is the collider.
  Justification: Shriram asked for skyscrapers reachable only with a "2x jump". Tower roofs sit 60–74 px above their neighbours versus a 53.3 px single jump, so the jump strength stayed as it was and the geometry demands the new rule.
  Tested explicitly: `fixed-jump-height`, `web-zip-double-jump-once`, `skyscrapers-need-web-zip`, plus the coyote/buffer boundaries.
  Also in this revision: level 1600 → 2500 px across three zones; spikes → taxis (two parked, four moving); death messages by cause; finish at x=2388.
- 2026-09-24 (prediction check, film capture): Predicted Failure A (eyes detach) did not occur with the redrawn head (engine close-ups, film B04).
  Failure B (route undershoot) was replaced by the new route fixture, which passes (14 ground marks + 3 web-zips).
  Failure C (zone labels hidden): the opposite happened. The zone banner is visible but can **cover the hero** mid-jump. This is an unpredicted defect found in the capture, logged in TEST-REPORT.md.

