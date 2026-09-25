# FRICTIONAL — walker-jumpman-shriram-a

Honest log of attempts, expectations, and what actually happened.
Human and AI contributions distinguished throughout.

---

## Entry 1 — 2026-09-24 — Project setup and codebase read

**What I tried:** Cloned the starter via `git clone`. Git failed with an Xcode library error (`dlopen libxcodebuildLoader.dylib`). Switched to `curl` download of the ZIP from GitHub.

**What happened:** ZIP download and extraction worked. All source files present.

**Who did what:** Claude Code ran the curl command and extracted the ZIP. I verified the file list looked correct.

**What I learned:** Git is broken on this machine due to an Xcode update mismatch. Need to fix Xcode CLI tools or use GitHub Desktop for submission. Note this as a known setup friction.

---

## Entry 2 — 2026-09-24 — Reading the starter code

**What I tried:** Read `player.gd`, `session.gd`, `first_steps.json`, `tuning.gd`, `test_game.gd`, `route_driver.gd`, `hud.gd` in full.

**Expected:** Straightforward—understand the draw system and level data format.

**What I found:**
- `_draw()` in `player.gd` uses local-space coordinates where y=0 is the player's feet. The collision shape spans y=-28 to y=0. All drawing must stay in that box.
- `session.gd _draw()` has the hazard spike drawing hard-coded to `y=320` (the main floor). Any raised-platform hazard would draw in the wrong place. Needed to fix this.
- The finish pole is also hard-coded to `y=320` at the base. Moving the finish requires updating the drawing to use `level.finish[1] + level.finish[3]` as the pole base.
- The background grid stops at `x=960` and the background rect covers only to `x=1400`. Both need extending for a 1600-wide level.
- `route_driver.gd` uses x-position-triggered jumps. New jumps needed for 3 new platforms.

**Who did what:** Claude Code read and summarized all files. I reviewed the summaries and identified the hard-coded y=320 drawing as the key risk.

**What I learned:** The visual drawing and physics collision are independent — fixing the collision data in JSON is not enough; the drawing code must also be updated to match.

---

## Entry 3 — 2026-09-24 — Jump feasibility calculation

**What I tried:** Claude Code computed exact jump trajectories using `jump_velocity=-320`, `gravity=960`, `speed=160` from `tuning.gd` to verify all three new gaps are reachable.

**Results:**
- Rooftop 1 (32 px up, 40 px gap): player lands at x≈1032 from jump at x=945. ✓
- Rooftop 2 (16 px up, 32 px gap): player lands at x≈1167 from jump at x=1070. Rooftop 2 set to start at x=1160 to have 7 px margin. ✓
- Rooftop 3 (16 px down, 48 px gap): player lands at x≈1374 from jump at x=1260. ✓
- Hazard clearance: at x=1108 (hazard position) during jump from x=1070, player's feet are at y≈239 — well above the hazard at y=272. ✓

**What I learned:** Placing Rooftop 2 too far right (x=1192) would cause the route-driver test to fail because the jump from x=1070 only carries 97.9 px horizontally at the landing height. Moved Rooftop 2 to x=1160. This is a real geometry constraint, not just an aesthetic choice.

---

## Entry 4 — 2026-09-24 — Implementation

**What I tried:** Applied all code changes: `player.gd _draw()`, `first_steps.json`, `session.gd _draw()`, `route_driver.gd`, `test_game.gd`, `hud.gd`.

**Expected:** Changes apply cleanly with no merge conflicts.

**What happened:** All edits applied. No conflicts—the starter has no uncommitted changes.

**Who did what:** Claude Code wrote all the GDScript and JSON edits. I approved the plan and reviewed each diff.

**Unresolved question:** The jump marks (945.0, 1070.0, 1260.0) are predicted from physics math. They have not been tested in Godot yet. If the `complete-real-route` test fails, I need to run Godot and inspect the `jump_marks_used` value to see how many marks the route consumed and where it stopped.

---

## Entry 5 — 2026-09-24 — Redraw, skyscrapers, web-zip, moving taxis (AI-recorded bullets, then Shriram's reflection)

*Recorded by Claude Code from the session transcript. The bullets are what was tried and checked, not Shriram's personal experience; Shriram's own reflection follows them.*

- **Trigger (Shriram):** screenshots of the running game with the request: villains and Spider-Man "look really bad"; add skyscrapers with a 2x jump; the web should reach the ceiling; taxi deaths said "spikes"; add taxis moving near and far.
- **Tried (Claude):** redrew all four characters, reviewing them through engine-rendered close-ups (`tests/capture_art.gd`). The first pass looked blurry from antialiasing, so antialiasing was turned off on fills. Doc Ock's upper tentacles crossed his face and were moved behind him.
- **Tried (Claude):** a web-zip air jump (`air_jumps = 1`) plus three tall solids. The route driver died three times while being tuned: onto moving taxi A, into taxi C, and landing on taxi D. It was fixed by moving jump marks and changing taxi 4's `phase` from 0.0 to 0.7. **That tuning is why the route test proves a route exists but not that the traffic is fair.**
- **Test response:** `web-zip-double-jump-once` failed first (rise 111.8 px against a bound of 110). Its bound was widened to 2.2 × 53.34 because a near-apex second jump predicts ≈107–112 px. `coyote-7` now counts ground jumps only, because a late press turns into a web-zip.
- **Result:** 29 mechanics + 9 keyboard checks pass (`evidence/mechanics-1790304898.29995.json`, `evidence/keyboard-1790304899.58816.json`).

**Shriram's reflection:**

So The villains and Spider-Man honestly looked rough like Goblin, Doc Ock, and Vulture didn't read as themselves at all, so those needed a full redraw. I also wanted real skyscrapers you could actually land on, with a 2x jump to reach them, a web that shoots up and touches the ceiling instead of that weak short arc, a death message that actually says "taxi" and "landed on civilians" instead of the generic "spikes" line, and taxis moving across both the near and far lanes so there's more ways to actually fail (not gonna lie, this makes the game way more fun).
Once I saw the redraws, the skyscrapers, the ceiling web-zip, the new death messages, and the moving taxis, I was genuinely impressed and called it fantastic, because it was. Later on, the Brutalist film came through too and I was happy with it, "video is great" was my exact reaction. There's a zone-banner overlap in there, but I chose to just note it rather than go back and fix it.
Not everything landed first try though. The very first pass at the villain and hero art was the whole reason I asked for a redraw in the first place and it wasn't it. 
On the decision-making side: I chose to submit late rather than rush out an unfinished film which i believe better late than sloppy. And when I noticed how often the @NikBearBrown handle shows up as a requirement, I looked into why it's there, decided it made sense, and kept the outro instead of re-rendering the whole thing.

## Entry 6 — 2026-09-24 — Film capture found things the tests didn't (AI-recorded)

- **Expectation:** a scripted capture would just replay the route.
- **What happened:** the capture exposed an interaction. With the air jump unspent, a press just before landing becomes a web-zip, not a buffered jump. The driver spends the web-zip first so the buffer can be shown truthfully.
- It also exposed a visual defect: the zone banner covers the hero during the first web-zip. It was **left unfixed** so the film matches the submitted build, and it's listed as a known defect.
- Mouse-click replay needed the real cursor: `Input.warp_mouse` plus a two-point calibration. Parsed mouse events alone didn't move the HUD's cursor.
- **Unresolved:** focus-loss pause can't be shown honestly by a scripted capture (unit-tested only).
- **Traceability:** `youtube/claude-liam-walker-jumpman-shriram-a-walkthrough/CAPTURE.md`, `capture/run-01-inputs.jsonl`, commit `1cbbb85` (game source) + the follow-up docs/film commit.

## Entry 7 — 2026-09-25 — My playtest (Shriram)

I  opened the project in Godot, hit F5, and played through with just the keyboard, from the main menu all the way to the flag, about 100 runs total. I ran through everything: movement with the arrows and A/D, jumping, the web-zip, pausing and resuming, the main menu, restarting, and I also died on purpose twice which was once on a taxi, once by missing a landing, just to check both death paths.

My expectations going in: a single jump, a second web-zip press mid-air, and nothing on a third press. I figured the glass tower would need the web-zip to clear, and the taxis would end up being the real difficulty spike.
That's pretty much how it played out. The controls worked exactly as expected as holding Space doesn't keep lifting him, the second press web-zips him higher, and a third press just does nothing. I think that's the right call, honestly. If he could keep climbing indefinitely he'd basically glide over everything and skip the ground obstacles entirely, and the whole game would lose its purpose.

At the first glass tower I was about to fall short, and the web-zip pulled me through right at the last second, that was the moment it actually felt like a real game to me. The moving taxis in Manhattan were, without question, the hardest part. Took me three tries the first time, and it's still tricky now, but it felt fair once I figured out the rhythm which was wait for the cabs, then time the jump.

Death messages checked out too: "Watch the taxis!" with the civilians line when a cab got me, and "Missed the landing" when I fell short. Retries were fast, back at the start in under a second each time. My clean run (a later run) came in at 19.2 seconds with 0 retries.

Spider-Man reads clearly, turning left and right looks natural, and the villains actually look like their comic versions now. Once I passed through them I realized they can't hurt me yet which meant no attacks on their end. I was fine with them being decorative for this version, but a first-time player only finds that out by walking through them.

Two things stood out. 

The zone banner still covers Spider-Man whenever I web-zip in levels 2 and 3 — it's translucent, but it still blocks the character, and this time I confirmed it's not just a Midtown thing, it happens in Manhattan too. And his two eyes are different sizes, which is apparently intentional (a three-quarter view thing), plus the chest spider logo is too small to actually see at normal size.

Changes I'd want next: move the zone banner higher or restyle it so it stops covering the player, redesign the face so the eyes read evenly and the logo's actually visible, and give the villains real powers and attacks so they're an actual part of the challenge instead of just background.

---

## Human vs. AI contribution summary

| Contribution | Human | AI (Claude Code) |
|---|---|---|
| Character concept (Spider-Man theme) | ✓ decided | — |
| Physics math verification | reviewed | ✓ calculated |
| Level geometry (platform x/y values) | approved | ✓ proposed |
| GDScript code edits | ✓ reviewed each change by playing the build; when something didn't work or looked wrong (taxi deaths still saying "spikes", villain art that didn't read as the characters), dug into what went wrong and directed the fix | ✓ wrote |
| Hard-coded y=320 bug identification | ✓ flagged after review | ✓ found in read |
| CHANGE-BRIEF, FRICTIONAL, SOURCES | directed | ✓ drafted |
| Playtesting | ✓ done: about 100 runs (Entry 7) | cannot do; ran scripted captures only |
| Villain/hero redraw request, skyscraper + 2x-jump, ceiling web, taxi messages, moving taxis | ✓ requested (from screenshots) | ✓ implemented + tested |
| Film (Brutalist godot-waikthrough, walker) | ✓ requested, watched and approved ("the video is great") | ✓ capture driver, script, narration (Kokoro), render, QC |
