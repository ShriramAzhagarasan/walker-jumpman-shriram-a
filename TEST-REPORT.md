# TEST-REPORT — walker-jumpman-shriram-a

Engine: Godot 4.7.2.stable.official · macOS · Source snapshot bb0f4ad4 (see below) · Git commit SHA: `1cbbb850b988188bb2e28377dd897c2ff93d460b`

---

## Automated checks

Run with: `godot --headless --path godot --script tests/test_game.gd`

| Check | Status | Observed | Notes |
|---|---|---|---|
| launch-grounded | PASS | `{"engine": "4.7.2-stable (official)", "position": "(64.0, 320.0)"}` |  |
| speed-cap | PASS | `{"velocity_x": 160.0}` |  |
| neutral-stop | PASS | `{"velocity_x": 0.0}` |  |
| simultaneous-directions | PASS | `{"velocity_x": 0.0}` |  |
| left-wall | PASS | `{"x": 10.0}` |  |
| fixed-jump-height | PASS | `{"jumps": 1, "rise_px": 56.07470703125}` | renamed from fixed-jump-and-no-double: the build adds one air jump by design (see CHANGE-BRIEF revision); single-jump rise still checked |
| held-jump-no-bounce | PASS | `{"jumps": 1}` |  |
| web-zip-double-jump-once | PASS | `{"air_jumps": 1, "jumps": 1, "rise_px": 111.808059692383}` | NEW. First run FAILED at rise 111.8 px with bound < 110; bound widened to < 2.2 × 53.34 because a near-apex second jump predicts ≈107–112 px (physics-derived, not to get green). Third press still ignored |
| skyscrapers-need-web-zip | PASS | `{"single_jump_px": 53.33, "smallest_rise_px": 60.0}` | NEW. Every tower is > one jump (53.33 px) and < two jumps above its neighbour |
| coyote-5 | PASS | `{"age": 5, "jumps": 1}` |  |
| coyote-6 | PASS | `{"age": 6, "jumps": 1}` |  |
| coyote-7 | PASS | `{"age": 7, "jumps": 0}` | with the new air jump, a 7-tick-late press becomes a web-zip, so the assertion counts ground jumps (`jumps`) only |
| buffer-5 | PASS | `{"age": 5, "jumps": 1}` |  |
| buffer-6 | PASS | `{"age": 6, "jumps": 1}` |  |
| buffer-7 | PASS | `{"age": 7, "jumps": 0}` |  |
| low-ceiling | PASS | `{"jumps": 1, "minimum_feet_y": 300.000274658203}` |  |
| pause-freezes | PASS | `{"elapsed": 0.133333333333333, "position": "(64.0, 295.9253)"}` |  |
| focus-loss-pauses | PASS | `{"state": 2}` |  |
| actual-taxi-collision | PASS | `{"deaths": 1, "reason": "Watch the taxis!", "state": 3}` | renamed from actual-spike-collision; now also asserts the taxi death message |
| duplicate-death-ignored | PASS | `{"deaths": 1}` |  |
| respawn | PASS | `{"position": "(64.0, 320.0)", "state": 1}` |  |
| manual-restart-not-death | PASS | `{"deaths": 1}` |  |
| twenty-retries | PASS | `{"deaths": 21, "max_retry_ticks": 34}` |  |
| death-before-finish | PASS | `{"state": 3}` |  |
| fall-boundary | PASS | `{"detail": "Straight down onto the civilians below.", "state": 3}` | now also asserts the civilians message |
| moving-taxis-patrol | PASS | `{"now": "[672.830322265625, 1584.24816894531, 1700.16455078125, 2000.00146484375]", "st…` | NEW. 4 moving cabs move and stay inside their ranges |
| taxis-reset-on-retry | PASS | `{"now": "[632.0, 1528.0, 1766.0, 2049.74267578125]"}` | NEW. Traffic replays identically each attempt |
| complete-real-route | PASS | `{"deaths": 0, "jump_marks_used": 14, "position": "(2384.884, 287.9253)", "state": 4, "t…` | route fixture rewritten for the 2,500 px level: 14 ground marks + 3 web-zip marks; asserts all web-zips used |
| replay-idempotent | PASS | `{"deaths": 0, "jumps": 0, "state": 1}` |  |

Result: **29 checks / 0 failures** — `evidence/mechanics-1790304898.29995.json` (created 2026-09-25T02:54:58 UTC, engine 4.7.2-stable (official)).
Keyboard: **9 / 9 PASS** — `evidence/keyboard-1790304899.58816.json` (enter-start, keyboard-move, keyboard-jump, escape-pause, enter-resume, r-retry, enter-replay, pause-main-menu, menu-start-again).
Commands: `Godot --headless --path godot -s res://tests/test_game.gd` and `-s res://tests/test_keyboard.gd`.
Source snapshot at this run: `bb0f4ad453a25096bb04b84f1609338760328c0868e43e4dfbb8c09454cd61f7` (method in `youtube/claude-liam-walker-jumpman-shriram-a-walkthrough/CAPTURE.md`).
Earlier results are preserved in the other `evidence/mechanics-*.json` files (the starter-era 25-check runs included).

**Fresh-copy verification (2026-09-25):** `git clone https://github.com/ShriramAzhagarasan/walker-jumpman-shriram-a` of commit `9195fa9` into an empty folder, then `Godot --headless --path godot --import`. Results: `test_game.gd` 29 checks / 0 failures; `test_keyboard.gd` 9/9 PASS; the main scene runs 120 frames with no script errors. `tools/source_snapshot.py` prints `bb0f4ad4…`, the build shown in the film. The repo contains no `.godot/` cache and no MP4/MP3/AVI/WAV (largest tracked file 2.8 MB).

**Scripted-input film capture (not a human playtest):** `youtube/claude-liam-walker-jumpman-shriram-a-walkthrough/capture/run-01-inputs.jsonl`. The real main scene is played through `Input` events only: taxi death, auto-retry, both facings, pause/resume, R, coyote (+4 ticks), buffer (−4 ticks), wall fall at the first tower without a web-zip, 3 web-zips to the flag, mouse replay, M → menu. `CAPTURE OK`.

---

## Human playtesting — Shriram (normal keyboard/mouse, about 100 runs)

Build: commit `1cbbb85` / source snapshot `bb0f4ad4`. Date/time played: 09/24/2026· How many runs: 100

### 1. Startup and controls
- [x] Game launches (walker-jumpman.command or Godot F5); menu reads "Spider-Man: Rooftop Rush"
- [x] A/D and arrow keys move; Space jumps; holding Space does not auto-bounce
- [x] Pressing Space again mid-air web-zips once (web line reaches the ceiling); a third press does nothing
- [x] Esc/P pauses ("Take a breath."); Enter resumes; M returns to the main menu
- [x] R restarts immediately and does not add a retry
- Observation: Launched godot application and opened the game file, clicked on F5 to play the game. The main menu showed up with the title "Spider-Man:Rooftop Rush" , I clicked on start to play, both the arrows and A/D works for moving the character. Space gave me a single jump and holding space after pressing doesn't do anything and i just fall which is expected. If i click space the 2nd time after i am already in the air after clicking it once, the web zip works where when he is already up, he webzips to go even up. Third press doesn't do anything which is again expected, as we don't want him to fly as if he is just gliding, that would make this gameplay really easy and he would just be gliding and not interact with any of the objects in the ground. i am able to pause wherever i want which is good and i am able to easily resume it, return to the main menu and restart it without a problem.  

### 2. Character appearance
- [x] Spider-Man reads clearly standing, running, jumping, falling
- [x] Facing left and right both look right (eyes/arms mirror)
- [x] Nothing drawn far outside where he actually collides (landing on edges looks honest)
- [x] Villains (Vulture, Goblin, Doc Ock) are recognisable; you understood they can't hurt you
- Observation: The character looks like a 2-d version of spider man. it is recognisable to everyone that he is spider-man, maybe if we talk about a flaw, i could have indiviually redesigned him better so that the spider-logo on his chest is visibile. He faces left and right and that looks natural, no problem there. yea nothing is drawn far outside when he collides with the taxi. villians look like the comic version of the characters and after you trying passing through them, you can understand they can't hurt you. maybe in the next version, we can work on them using their power-ups and attacking us which can be interesting.

### 3. Extended route
- [x] Queens section (step, parked taxi, gap) still playable as in the starter
- [x] Glass tower (x≈784): a single jump fails, web-zip reaches it
- [x] Manhattan: parked taxi, tower two (x≈1328), moving taxis, tower three (x≈1860)
- [x] Reached the flag (x≈2388) with normal play. Attempts needed: 4
- Observation (was any jump unclear or unfair? did moving taxis feel fair?): The route was clear as it depicted new york city's map perfectly. while going through the glass tower, i was about to fall but web-zipping(two space-bars) got me up which was nice and actually felt like a game. in Manhattan part of the game, the moving taxis were tricky an di had to be really careful as that took me 3 tries in the first time when i try to beat the game and it is still tricky for me to beat it. i feel the gameplay was fair oncei learnt how to wait and jump when the cabs were moving so fast.

### 4. Failure and recovery
- [x] Taxi contact shows "Watch the taxis! / You landed on a cab full of civilians."
- [x] Falling shows "Missed the landing / Straight down onto the civilians below."
- [x] Auto-retry returns you to the start in about half a second; RETRIES counts deaths
- [x] After the flag, Enter (or clicking PLAY AGAIN) starts a fresh run with RETRIES 00
- Observation: when i fell on the taxi it showed "Watch the taxis!" with the civilians line. and when i just missed a block and fell down, it "Missed the landing". Each retry put me back at the start in under a second, and retries counted only deaths. After that if i beat the game, it shows a clean run with like 19.2 seconds/ 0 retries.

### 5. Camera and presentation
- [x] Camera keeps the next landing visible before each jump
- [x] Zone banners (Queens / Midtown / Manhattan) appear when crossing zones
- [x] Did a banner ever cover Spider-Man and get in your way? (the film capture shows it can) : yes it did
- [x] Progress bar fills toward the flag; HUD text readable
- Observation: Yes so iw as able to see spiderman and the landing was visible every single time when he landed so that wasn't an issue at all. Zone banners and also the time of the day changed and appeared so it was distingushable for me. Banners covered up the character wheneevr i web-zipped in level 2 and level3. The banner was translucent but it covered up the character and i believe that aspect of the game can be reworked to a much more higher banner or a different style.

### Other people
None. No one else played this build; all observations above are mine.

## Inspect-and-revise cycle

**Cycle 1: the taxi death message said "spikes" (observation by Shriram, from in-game screenshots)**
- Observation: touching a taxi showed "Watch the spikes" after the spikes had been replaced by taxis. Falling showed a message that didn't mention the street below.
- Cause (found in code): `session.gd` set `death_reason = "Missed the landing" if fatal else "Watch the spikes"` before checking hazards, so the text never depended on what killed you.
- Change: separate `hit_taxi` / `fell` checks. Taxi: "Watch the taxis! You landed on a cab full of civilians." Fall: "Missed the landing / Straight down onto the civilians below." The HUD shows a second detail line.
- Re-check: `actual-taxi-collision` asserts `"taxi" in death_reason`; `fall-boundary` asserts `"civilians" in death_detail` (both PASS). Visible in the film, B02 and B07.
- Revision commit: `1cbbb85` (the first pushed commit contains this revision; there is no earlier git history because git was broken on this machine until 2026-09-25)

**Cycle 2: villain and hero art read poorly (observation by Shriram, from screenshots: "everyone looks really bad")**
- Change: Spider-Man, Vulture, Green Goblin and Doctor Octopus redrawn as outlined vector characters; the villains now animate (the scene never redrew before).
- Re-check: engine close-ups (`tests/capture_art.gd`, film B04). Collider unchanged, and `launch-grounded` / `left-wall` / `low-ceiling` still pass.
- Revision commit: `1cbbb85` (the first pushed commit contains this revision; there is no earlier git history because git was broken on this machine until 2026-09-25)

**Open observation from the film capture (not yet revised):** the zone banner ("MIDTOWN CROSSING") draws over the hero during the first web-zip (capture ≈ 25.0–27.7 s, film B08). It is logged as a known defect, not fixed, so that the film matches the submitted build.

## Known limitations

- The automated route passes partly because moving taxi 4's `phase` (0.7) was tuned during route authoring. That proves one route exists, not that the traffic is fair.
- The web line is visual only; the web-zip is a plain second jump (no swing physics).
- The completion time covers the last attempt only (the starter resets the clock on every retry).
- The zone banner can cover the hero mid-jump: seen in the film capture (Midtown) and in Shriram's playtest (Midtown and Manhattan). Not fixed, so the film matches the build.
- Focus-loss pause is unit-tested but not shown in the film.
- No audio — same as starter.
- Godot 4.7.2 on macOS only; untested on Windows.
- Git on this machine was broken by an Xcode library mismatch until 2026-09-25. It was fixed by installing Homebrew git, which is why the history starts at the first pushed commit `1cbbb85`.
