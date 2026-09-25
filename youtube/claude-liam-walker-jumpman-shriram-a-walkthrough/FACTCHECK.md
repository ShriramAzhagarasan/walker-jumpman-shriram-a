# FACTCHECK — Rooftop Rush: Extending Walker Jumpman

Every factual claim spoken or shown, checked against the source at build
`bb0f4ad453a25096bb04b84f1609338760328c0868e43e4dfbb8c09454cd61f7`, the capture log, or the test evidence.

| Beat | Claim | Verdict | Source / check |
|---|---|---|---|
| B00 | The on-screen Walker prompt is an illustrative reconstruction, not a transcript | TRUE (labeled) | Topic line on screen. The real work was many smaller requests (see PROMPTS.md) |
| B00 | 29 mechanics + 9 keyboard checks pass | TRUE | `evidence/mechanics-1790304898.29995.json` (29 / 0 failures), `evidence/keyboard-1790304899.58816.json` (9 PASS), rerun at this build |
| B01 | Level stretched from 960 to 2,500 px | TRUE | Starter README/BUILD-REPORT: "A 960 × 360 level". `levels/first_steps.json` `"width": 2500` |
| B01 | Skyscrapers only reachable with a second jump | TRUE | Test `skyscrapers-need-web-zip` (smallest rise 60 px > 53.33); capture B07 |
| B02 | Enter starts; driver skips the jump at the parked taxi on purpose | TRUE | Input log tick 150 confirm; `taxi_attempt` phase has no jump at x=292 |
| B02 | The starter's spikes became a cab; the kill zone is the cab outline | TRUE | `session.gd` `_add_area`: `CollisionPolygon2D` from `TAXI_SHAPE` (was three spike triangles) |
| B03 | Back at the start about half a second later | TRUE | Death tick 256 → respawn tick 290 = 0.57 s; `retry_remaining = 0.55` |
| B03 | The whole drawing mirrors | TRUE | `player.gd` `_draw`: `draw_set_transform(Vector2.ZERO, 0.0, Vector2(facing, 1.0))` |
| B03 | Pause freezes everything, timer included | TRUE | HUD timer 05.0 s holds during the pause in the capture; `elapsed` only advances in PLAYING; test `pause-freezes` |
| B03 | R restart is not a death; counter stays at one | TRUE | RETRIES 01 before and after tick 880; test `manual-restart-not-death` |
| B04 | Close-ups rendered by the engine in a test harness, not gameplay | TRUE (labeled) | `tests/capture_art.gd` sets position/zoom; the card says so |
| B04 | Limbs are capsules with an ink outline | TRUE | `player.gd` `_capsule()` two-pass outline/fill |
| B04 | Collider is the starter's, 18 × 28 | TRUE | `player.gd` `_ready`: `RectangleShape2D` size `(18, 28)` at `(0, -14)`, unchanged from the starter |
| B04 | Villains animate but can't hurt you | TRUE | `villains.gd` is draw-only; no Area2D/collision is created for villains |
| B05 | Jump strength and gravity are the starter's numbers | TRUE | `tuning.gd` `jump_velocity = -320.0`, `gravity = 960.0` (GDD 0.2.0 values, unchanged) |
| B05 | One jump rises about 53 px | TRUE | 320² / (2 × 960) = 53.33; test `fixed-jump-height` measures ≈ 53.3 |
| B05 | Tower roofs sit 60–74 px above their neighbours | TRUE | Rows: 784 top 246 vs 320 (74); 1328 top 212 vs 272 (60); 1860 top 204 vs 272 (68) |
| B05 | The only new movement rule is one air jump | TRUE | `tuning.gd` adds `air_jumps = 1`, `air_jump_velocity = -320`; speed/accel/coyote/buffer unchanged |
| B06 | Press 4 ticks late; coyote honours it | TRUE | Log: left floor 1136, press 1140, jump fires 1142 (coyote window 6) |
| B06 | Press 4 ticks before touchdown; buffer fires on landing | TRUE | Log: press 1208 (air jump spent), jump fires 1212 (buffer window 6) |
| B07 | Out of air jumps, the hop is only a ground jump; meets the wall | TRUE | Log: death 1268 at x=775.3 below the tower (x 784, top 246); reason "Missed the landing" |
| B08 | Same start, same traffic timing | TRUE | Clean route starts on the respawn tick; taxis are driven by `elapsed`, which resets on retry |
| B08 | Web fires from the wrist to the ceiling | TRUE | `player.gd` `WEB_CEILING_Y = 78` (just under the HUD); line drawn from the far hand |
| B08 | Zone banner covers him: a real defect | TRUE (observed) | Capture ~25.0–27.7 s: MIDTOWN CROSSING banner over the hero |
| B09 | Parked cab, tower two, moving cabs, tower three, flag | TRUE | Log ticks 1691 (hop over the parked cab at x=1070), 1762, 1961 (zips), 2184 (COMPLETE) |
| B10 | Time covers this attempt only; clock resets every retry | TRUE | `restart_attempt()` sets `elapsed = 0.0` (starter behaviour); card shows 14.7 s with 2 retries |
| B10 | Driver clicks Play Again with the mouse; replay starts at zero | TRUE | Log tick 2604 click at HUD (319.6, 214.6) → state PLAYING tick 2606, retries 0 |
| B10 | Escape, then M → main menu | TRUE | Log ticks 2726, 2816 → state MENU |
| B11 | One bound was widened to match the physics, and that is written down | TRUE | `web-zip-double-jump-once` first failed at rise 111.8 px (bound < 110). Widened to < 2.2 × 53.34 because a near-apex double jump predicts ≈ 107–112 px. Recorded in TEST-REPORT.md |
| B11 | The route check passes partly because one taxi's phase was tuned to it | TRUE | `first_steps.json` taxi 4 `phase: 0.7` was set during route tuning (FRICTIONAL.md) |
| B12 | Shriram chose the concept, rejected the first villain art, and asked for skyscrapers, web-zip, ceiling web and moving cabs | TRUE | Shriram's session requests (PROMPTS.md §Human requests) |
| B12 | Claude Code wrote the drawing code, level, tests, script, render | TRUE | SOURCES.md; this reel's tools/ |
| B12 | Starter is Nik Bear Brown's walker-jumpman | TRUE | https://github.com/nikbearbrown/walker-jumpman |
| B13 | Web is visual only | TRUE | Web state affects drawing only; physics uses `velocity` + `air_jumps` |
| B13 | Next: checkpoint at Manhattan Heights (x = 1000) | PROPOSAL | Not built; labeled "Next" |

Corrections made while scripting:
- An early draft said "ground jumps alone should fail". The final take spends the web-zip earlier (to show the buffer), so the claim became "without a web-zip left".
- An early draft said the completion time was the run time. It is the last attempt only, and the narration says so.
