# CAPTURE — Rooftop Rush walkthrough

## What was recorded

| Item | Value |
|---|---|
| Game | walker-jumpman-shriram-a (`godot/`) |
| Build id | source snapshot SHA-256 `bb0f4ad453a25096bb04b84f1609338760328c0868e43e4dfbb8c09454cd61f7` |
| Hash method | `tools/source_snapshot.py`: for each file under `godot/` except `.godot/`, sorted by POSIX path, hash `"<relpath>\0<sha256(file)>\n"`; SHA-256 of the concatenation. `python3 tools/source_snapshot.py <repo> --list` prints every file hash. |
| Engine | Godot 4.7.2.stable.official.ed1daf0bf, macOS (Apple M1 Pro), GL Compatibility |
| Method | **scripted-input**, not a human playtest |
| Recorder | Godot Movie Maker: `--write-movie capture/run-01.avi --fixed-fps 30 --resolution 3840x2160` (offline render; **not** evidence of real-time FPS) |
| Output | `capture/run-01.mp4` — H.264 CRF 12 transcode of the MJPEG AVI (quality 0.97), 3840×2160, 30 fps, 1470 frames, 49.0 s, no audio (the game has no sound) |
| Input log | `capture/run-01-inputs.jsonl` — every input and observed event against the 60 Hz physics tick |

Movie Maker runs two 60 Hz physics ticks per 30 fps frame, so **capture seconds = tick ÷ 60**,
at normal game speed. No gameplay clip in the film is slowed, sped up or retimed.

## Isolated harness copy

`capture-project/` is a copy of `godot/` (rsync, excluding `.godot/`). It differs from the
game source in exactly two ways (`diff -rq godot capture-project`):

1. `project.godot`: window override 1280×720 → 3840×2160, plus `[editor] movie_writer/mjpeg_quality=0.97`.
   The logical canvas stays 640×360 with `canvas_items` stretch, so the vector drawing renders natively at 4K.
   The play area and camera are unchanged.
2. `capture_driver.gd` added (the input driver). No game file is modified.

## The driver's rules

`capture_driver.gd` instantiates the real `res://game/main.tscn` and plays only through input:

- Movement and jump: `Input.action_press` / `Input.action_release` (the player polls them). Jump is held for 3 ticks.
- Menu, pause, retry and main menu: `Input.parse_input_event(InputEventAction)`, because `session.gd` handles them in `_unhandled_input`.
- Mouse replay: `Input.warp_mouse` moves the **real cursor** (the HUD reads the real cursor position), calibrated from two warped points. Then a real `InputEventMouseButton` left click. The log records the HUD point `(319.6, 214.6)`, inside the button.
- It observes position and state to choose inputs. It never teleports, sets state, disables collision or touches the player's test hooks (`test_control`, `test_axis`, …).
- It asserts the clean route completes and exits nonzero otherwise (`CAPTURE OK` in `capture/movie-maker.log`).

### Take sequence (ticks from the log)

| Tick | s | Event |
|---|---|---|
| 150 | 2.50 | Enter starts |
| 256 | 4.27 | Contact with the parked taxi → "Watch the taxis!" (RETRIES 01) |
| 290 | 4.83 | Auto-retry |
| 381–399 | 6.35–6.65 | Turn left, idle facing left |
| 590 / 800 | 9.83 / 13.33 | Esc pause / Enter resume |
| 880 | 14.67 | R manual restart (RETRIES stays 01) |
| 1136 → 1140 → 1142 | 18.93–19.03 | Walk off the gap edge; press 4 ticks late; coyote jump fires |
| 1161 | 19.35 | Web-zip spent in the air |
| 1208 → 1212 | 20.13–20.20 | Press 4 ticks before landing; buffered jump fires on touchdown |
| 1268 | 21.13 | Ground jump hits the first tower wall → "Missed the landing" (RETRIES 02) |
| 1302 | 21.70 | Respawn; the clean route starts on this tick (same attempt clock as the tested route) |
| 1546 / 1762 / 1961 | 25.77 / 29.37 / 32.68 | Web-zips onto towers 1, 2, 3 |
| 2184 | 36.40 | Flag → COMPLETE |
| 2604 → 2606 | 43.40 | Mouse click PLAY AGAIN → fresh session, RETRIES 00 |
| 2726 / 2816 | 45.43 / 46.93 | Esc, then M → main menu |

## Revisions to the driver (logged honestly)

1. The first take ran with short waits. It was re-paced with longer menu, idle, pause and completion waits so the narration can follow real actions. Game code and speed were unchanged.
2. Coyote, buffer and main-menu segments were added so those implemented controls are shown, not just unit-tested.
   The first coyote try landed on moving taxi A (a real death, logged). The start of attempt 3 was delayed 100 ticks: a headless sweep found 80–120 all work, and 100 is the middle. With that delay the traffic is elsewhere. The game was not changed.
3. Discovered interaction: while an air jump is unspent, a press just before landing becomes a web-zip, not a buffered jump (by design in `player.gd`). The driver spends the web-zip first, then shows the buffer.
4. Mouse replay: parsed mouse events did not move the HUD's cursor, and the first warp missed because of the Retina/clamped window scale. The two-point calibration hit the button. Earlier misses are in this file, not in the film.

## Stills (B04)

`evidence/art/*.png` were rendered by `tests/capture_art.gd` in the harness copy. That script **sets positions and camera zoom directly**: it is a test harness for close-ups, not gameplay. The window was clamped to 3456×1944 by the display, and `tools/make_character_sheet.py` composes the 3840×2160 card from native-pixel or downscaled crops, never upscaled. The card is labeled on screen.

## Not shown

- **focus-loss pause:** implemented (`session.gd` pauses on `focus_exited` outside test mode). It needs a real OS focus change, which the scripted capture must not fake. Only the unit test `focus-loss-pauses` covers it, so `coverage.json` lists it as implemented with empty evidence.
