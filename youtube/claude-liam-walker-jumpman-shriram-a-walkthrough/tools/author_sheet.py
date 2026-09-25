#!/usr/bin/env python3
"""Author beat_sheet.json for the Rooftop Rush walkthrough (godot-waikthrough, walker mode).

Gameplay clip ranges are taken from capture/run-01-inputs.jsonl (tick / 60 = capture
seconds; Movie Maker at --fixed-fps 30 runs two 60 Hz physics ticks per frame).
Re-running this script overwrites narration/show/props but keeps measured audio
fields if the narration text is unchanged.
"""
import json
from pathlib import Path

R = Path(__file__).resolve().parents[1]
TITLE = "Rooftop Rush: Extending Walker Jumpman"
SLUG = "claude-liam-walker-jumpman-shriram-a-walkthrough"
BUILD = "bb0f4ad453a25096bb04b84f1609338760328c0868e43e4dfbb8c09454cd61f7"
B8 = BUILD[:8]
TOPIC = "WALKER · GODOT WALKTHROUGH"

def remotion(pattern, props, show, **kw):
    return {"type": "GRAPHIC", "class": "SHOW", "source": "remotion", "show": show,
            "remotion": {"pattern": pattern, "props": props}, **kw}

def gameplay(start, end, show, note):
    return {"type": "GAMEPLAY", "class": "SHOW", "source": "own", "treatment": "none",
            "capture": {"id": "run-01", "start_s": start, "end_s": end, "method": "scripted-input"},
            "label": "SCRIPTED-INPUT CAPTURE · real engine run · not a human playtest",
            "hold_policy": "labeled final-frame hold (HELD FRAME) if narration outlasts the action",
            "show": show, "note": note}

beats = [
 {"beat_id": "B00", "act": "ASK",
  "role_note": "COLD OPEN LAW + walker B00: 'Please use Walker to convert my game design document about …'. Labeled on screen as an illustrative reconstruction (topic line), never a transcript. Ask lands answered with the actual built result.",
  "narration_text": "Hej, this is Liam, in for Bear. The prompt on screen is an illustrative reconstruction, not a transcript. Shriram's real work happened over many smaller requests. But this is the shape of the ask: take the walker-jumpman starter, give it a new hero, extend the level, and keep the retry loop honest.",
  "shot": remotion("ClaudeComposerAsk", {
      "greeting": "Hej, Liam", "topic": "ILLUSTRATIVE RECONSTRUCTION · NOT A TRANSCRIPT",
      "segment": "Rooftop Rush",
      "command": "Please use Walker to convert my game design document about Spider-Man: Rooftop Rush, an extension of the walker-jumpman starter with a new hero, three New York zones, skyscrapers and moving taxis, into a playable Godot project.",
      "runningText": "reading godot/ and CHANGE-BRIEF.md…", "folderLabel": "@NikBearBrown",
      "modelLabel": "Claude", "effortLabel": "High",
      "output": ["Spider-Man hero, 2,500 px level, three zones.", "Web-zip double jump for three skyscrapers.", "29 mechanics + 9 keyboard checks pass."]},
      [{"at": "0.05", "event": "composer fades in; greeting 'Hej, Liam'"},
       {"at": "0.15", "event": "topic line reads ILLUSTRATIVE RECONSTRUCTION · NOT A TRANSCRIPT"},
       {"at": "0.25", "event": "the Walker ask types into the composer"},
       {"at": "0.7", "event": "send arms; three result lines land"}])},
 {"beat_id": "B01", "act": "BLUF", "lead_silence_s": 0.8,
  "role_note": "EXECUTIVE-SUMMARY LAW — hesitant writer. Misconception 'reskins' corrected to 'extends' (single token; the component splits on whitespace): the film's claim is that the level and the rules grew, not just the art.",
  "narration_text": "Rooftop Rush extends walker-jumpman. It doesn't just reskin it. A new Spider-Man, a level stretched from nine hundred sixty to twenty-five hundred pixels, and skyscrapers you can only reach with a second, web-zip jump.",
  "shot": remotion("BrutalistHesitantWriter", {
      "contextTitle": "What was built",
      "text": "Rooftop Rush reskins walker-jumpman.\nSpider-Man, three zones, 2,500 px of rooftops.\nSkyscrapers demand a second, web-zip jump.",
      "triggerWords": "reskins", "replacementWords": "extends",
      "fontSize": 84, "lineSpacing": 2.6, "align": "center", "seed": "7270",
      "mistakeRate": 2, "hesitateWithin": 0, "hesitateBetween": 1, "charMs": 8,
      "ink": "#3D3929", "accent": "#D97757", "bg": "#FAF9F5"},
      [{"at": "0.08", "event": "'Rooftop Rush reskins walker-jumpman.' types"},
       {"at": "0.3", "event": "'reskins' struck in terracotta; 'extends' typed in"},
       {"at": "0.55", "event": "lines two and three complete"}])},
 {"beat_id": "B02", "act": "PLAY",
  "role_note": "Gameplay: menu → start → deliberate taxi contact. Capture 0.00–4.70 s (Enter tick 150 = 2.50 s; death tick 256 = 4.27 s).",
  "narration_text": "Real engine, scripted input. Enter starts. The driver skips the jump at the parked taxi. Contact. Watch the taxis. The starter's spikes became a cab, and the kill zone is the cab's own outline.",
  "shot": gameplay(0.0, 4.70,
      [{"at": "0.0", "event": "menu modal: Spider-Man: Rooftop Rush"}, {"at": "2.50s", "event": "Enter (InputEventAction confirm)"},
       {"at": "3.08s", "event": "hop onto the step"}, {"at": "4.27s", "event": "contact with parked taxi; 'Watch the taxis!' overlay"}],
      "Failure: real hazard contact through normal input.")},
 {"beat_id": "B03", "act": "PLAY",
  "role_note": "Gameplay: auto-retry, both facings, pause/resume, manual R retry. Capture 4.70–15.60 s.",
  "narration_text": "Half a second later, we're back at the start. He turns left, and the whole drawing mirrors with him. Escape pauses, and everything freezes, timer included. Enter resumes. Then R restarts on purpose, and the retry counter stays at one, because a manual restart isn't a death.",
  "shot": gameplay(4.70, 15.60,
      [{"at": "4.83s", "event": "respawn at x=64, RETRIES 01"}, {"at": "6.35s", "event": "turns left; idles facing left"},
       {"at": "9.83s", "event": "Esc: 'Take a breath.' pause modal"}, {"at": "13.33s", "event": "Enter resumes"},
       {"at": "14.67s", "event": "R: manual restart; RETRIES stays 01"}],
      "Recovery, facing, pause/resume and manual retry.")},
 {"beat_id": "B04", "act": "CHARACTER",
  "role_note": "Engine-rendered stills (tests/capture_art.gd in the isolated copy; camera zoom in a test harness). Labeled on the card as not gameplay. Native pixels or downscale only.",
  "narration_text": "Here's the new hero up close, rendered by the engine in a test harness, not gameplay. Every limb is a capsule with an ink outline, drawn in player dot g d. Underneath, the collider is the starter's, unchanged: eighteen by twenty-eight. The villains are background art. They animate, but they can't hurt you.",
  "shot": {"type": "STILL", "class": "SHOW", "source": "own", "motion": "hold", "treatment": "none",
           "show": [{"at": "0.0", "event": "character sheet: run, jump with web, idle; Vulture, Goblin, Doc Ock"}],
           "note": "media/B04.png from tools/make_character_sheet.py"}},
 {"beat_id": "B05", "act": "CAUSE",
  "role_note": "Source cause → prediction. ClaudeCodeBeat shows real file lines only (tuning.gd lines 6-7 and 11-13; first_steps.json skyscraper rows).",
  "narration_text": "Here's the cause. Jump strength and gravity are the starter's numbers, untouched, so one jump rises about fifty-three pixels. Each skyscraper roof sits sixty to seventy-four pixels above its neighbour. The only new rule is one air jump. That makes a testable prediction: without a web-zip left, the first tower is out of reach.",
  "shot": remotion("ClaudeCodeBeat", {
      "title": "tuning.gd + first_steps.json (actual lines)",
      "code": "# godot/features/player/tuning.gd\n@export var jump_velocity: float = -320.0\n@export var gravity: float = 960.0\n## Web-zip double jump: one extra jump in the air, needed to reach skyscraper roofs.\n@export var air_jumps: int = 1\n@export var air_jump_velocity: float = -320.0\n\n# godot/levels/first_steps.json  (x, top y, width, height)\n[512, 320, 224, 64],\n[576, 288, 48, 32],\n[784, 246, 80, 154],",
      "sparkLine": "53 px jump. 74 px tower.", "language": "gdscript", "largeText": False, "brandLabel": "@NikBearBrown"},
      [{"at": "0.1", "event": "tuning.gd lines: jump_velocity, gravity"}, {"at": "0.45", "event": "air_jumps = 1 lines"},
       {"at": "0.7", "event": "level rows: roof at y 320, block 288, tower 246"}])},
 {"beat_id": "B06", "act": "PLAY",
  "role_note": "Gameplay, attempt 3: coyote jump and buffered jump with tick evidence. Capture 15.60–20.45 s. Input log: left floor tick 1136, press 1140 (+4, coyote window 6) -> jump 1142; web-zip 1161; press in air 1208 (buffer window 6) -> jump on landing 1212 (+4). Hold overlay lists these log lines.",
  "narration_text": "Attempt three shows the forgiveness windows. He walks off the gap edge, and the jump press comes four ticks late. Coyote time still honours it. He spends his web-zip in the air, then presses four ticks before touchdown, and the buffer fires the jump on landing.",
  "shot": gameplay(15.60, 20.45,
      [{"at": "16.33s", "event": "attempt 3 starts"}, {"at": "18.93s", "event": "walks off the gap edge (tick 1136)"},
       {"at": "19.00s", "event": "jump pressed 4 ticks late; coyote jump fires (tick 1142)"}, {"at": "19.35s", "event": "web-zip spent in the air"},
       {"at": "20.13s", "event": "press 4 ticks before landing"}, {"at": "20.20s", "event": "buffered jump fires on touchdown"}],
      "Timing-sensitive features shown as a sequence plus input-log ticks (overlay on the held frame).")
      | {"hold_overlay": ["INPUT LOG · capture/run-01-inputs.jsonl · 60 Hz ticks",
                          "1136  left the floor at the gap edge (no jump)",
                          "1140  jump pressed, 4 ticks late (coyote window 6)  ->  1142 jump fires",
                          "1161  web-zip: the one air jump is spent",
                          "1208  jump pressed in the air (buffer window 6)  ->  1212 fires on landing"]}},
 {"beat_id": "B07", "act": "PLAY",
  "role_note": "Effect of the source cause: with the air jump spent, a ground jump meets the tower wall. Capture 20.45–21.65 s; death tick 1268 = 21.13 s.",
  "narration_text": "Now he's out of air jumps, so that hop is only a ground jump. It meets the tower wall, not the roof. Missed the landing.",
  "shot": gameplay(20.45, 21.65,
      [{"at": "20.6s", "event": "ground jump toward the first tower"}, {"at": "20.9s", "event": "hits the wall below the roof, falls"},
       {"at": "21.13s", "event": "'Missed the landing' overlay; RETRIES 02"}],
      "Prediction confirmed in the engine: one ground jump cannot reach the first skyscraper.")},
 {"beat_id": "B08", "act": "PLAY",
  "role_note": "Effect, part 2: web-zip. Capture 21.65–27.68 s; air press tick 1546 = 25.77 s.",
  "narration_text": "Clean run: same start, same traffic timing. Up the block, launch, and a second press in the air. The web fires from his wrist to the ceiling, and he lands on the glass tower. And notice the zone banner sitting right on top of him. That's a real defect this capture caught.",
  "shot": gameplay(21.65, 27.68,
      [{"at": "21.70s", "event": "respawn; clean route begins"}, {"at": "25.43s", "event": "launch from block"},
       {"at": "25.77s", "event": "air press: web line to the ceiling"}, {"at": "26.4s", "event": "lands on the tower roof"}, {"at": "25.0s", "event": "MIDTOWN CROSSING banner overlaps the hero (observed defect)"}],
      "New landing 1: Midtown glass tower via web-zip.")},
 {"beat_id": "B09", "act": "PLAY",
  "role_note": "Manhattan section to the flag. Capture 27.68–35.88 s; zips at 29.37 s and 32.68 s; flag reached 0.52 s into B10; zips at 28.68 s and 32.00 s; COMPLETE tick 2143 = 35.72 s.",
  "narration_text": "Into Manhattan. Over the parked cab. Web-zip, tower two. Down past two moving cabs. Web-zip, tower three. One more cab, two more roofs, and the flag.",
  "shot": gameplay(27.68, 35.88,
      [{"at": "28.18s", "event": "hop over the parked taxi (tick 1691)"}, {"at": "29.37s", "event": "web-zip onto tower two"},
       {"at": "31.5s", "event": "roofs with moving taxis"}, {"at": "32.68s", "event": "web-zip onto tower three"},
       {"at": "35.88s", "event": "approach to the flag (reached at 36.40 s, next beat)"}],
      "New landings 2 and 3; relocated finish at x=2388.")},
 {"beat_id": "B10", "act": "PLAY",
  "role_note": "Completion, mouse-click replay, pause, M main menu. Capture 35.88–49.00 s; COMPLETE tick 2184 = 36.40 s; real cursor warped + left click at tick 2604 = 43.40 s (HUD point 319.6, 214.6 inside the button); replay tick 2606; Esc 45.43 s; M 46.93 s -> MENU.",
  "narration_text": "You're Amazing, Spider-Man, with two retries. That time covers this attempt only, because the clock resets on every retry. This time the driver clicks Play Again with the mouse, and the replay starts clean at zero. Escape, then M, and we're back at the main menu.",
  "shot": gameplay(35.88, 49.00,
      [{"at": "36.40s", "event": "flag reached; completion modal: time / 2 retries"}, {"at": "43.40s", "event": "mouse click on PLAY AGAIN"},
       {"at": "43.43s", "event": "fresh session, RETRIES 00"}, {"at": "45.43s", "event": "Esc pause"}, {"at": "46.93s", "event": "M: main menu"}],
      "Completion, replay by mouse, and return to the main menu.")},
 {"beat_id": "B11", "act": "TESTS",
  "role_note": "Reconstructed terminal view of recorded output (lines reformatted from evidence/mechanics-*.json and the keyboard run at this build). Labeled in the source line.",
  "narration_text": "What was tested: twenty-nine mechanics checks and nine keyboard checks, all passing on this build. One bound was set too tight and was widened to match the physics, which is written down. And an honest catch: the route check passes partly because one taxi's phase was tuned to that route.",
  "shot": remotion("WalkerGodotSetup", {
      "mode": "terminal", "title": "What was tested.", "sparkLine": "Checks pass. Feel is untested.",
      "source": "Reconstructed terminal view · lines reformatted from evidence/mechanics-1790304898.29995.json · build " + B8,
      "command": "godot --headless --path godot -s res://tests/test_game.gd",
      "lines": ["web-zip-double-jump-once   PASS  rise 111.8 px · 1 air jump",
                "skyscrapers-need-web-zip   PASS  smallest rise 60 px > 53.3",
                "actual-taxi-collision      PASS  \"Watch the taxis!\"",
                "moving-taxis-patrol        PASS  4 cabs stay in range",
                "complete-real-route        PASS  874 ticks · 0 deaths · 3 web-zips",
                "WALKER TESTS: 29 checks / 0 failures",
                "test_keyboard.gd           9 / 9 PASS"],
      "selected": 4},
      [{"at": "0.05", "event": "recorded command"}, {"at": "0.2", "event": "check lines reveal in order"},
       {"at": "0.8", "event": "route line highlighted during the tuning caveat"}])},
 {"beat_id": "B12", "act": "CREDITS",
  "role_note": "Human vs AI contributions and the demonstrated revision.",
  "narration_text": "Who did what. Shriram chose the concept, rejected the first villain art, and asked for the skyscrapers, the web-zip, the ceiling web and the moving cabs. Claude Code wrote the drawing code, the level, the tests, this script and this render. The starter is Nik Bear Brown's walker-jumpman. The build shown is source snapshot b b zero f, four a d four.",
  "shot": remotion("WalkerGodotSetup", {
      "mode": "comparison", "title": "Who did what.", "sparkLine": "Human decides. AI builds.",
      "source": "Starter: github.com/nikbearbrown/walker-jumpman · source snapshot " + B8 + " (SHA-256 in README)",
      "labels": ["Shriram decided", "Claude Code built"],
      "details": ["Spider-Man concept, three NYC zones\nRejected the first villain art\nAsked for skyscrapers + web-zip,\nceiling web, moving taxis, civilian messages",
                  "Drawing code, level geometry, tests\nRoute and taxi-phase tuning\nCapture driver, script, narration, render\nBuild " + B8],
      "selected": 0},
      [{"at": "0.1", "event": "Shriram panel"}, {"at": "0.45", "event": "Claude Code panel"}, {"at": "0.8", "event": "starter + build line"}])},
 {"beat_id": "B13", "act": "VERDICT", "lead_silence_s": 0.5,
  "role_note": "your-turn block 1: handoff (prior beat is Liam → 'Let's recap with Claude.') + verdict. Separates working / uncertain / known limits / next.",
  "narration_text": "Let's recap with Claude. Working: a new hero, a twenty-five-hundred-pixel route, three web-zip towers, taxi and fall retries, and replay. Uncertain: whether the moving cabs feel fair to a first-time human, since one cab's phase was tuned to the test route. Known defects: the zone banner can cover the hero mid-jump, and the web is visual only. Next: a checkpoint at Manhattan Heights, so a late cab doesn't cost two thousand pixels.",
  "shot": remotion("ClaudeVerdictArtifact", {
      "artifactTitle": "Verdict", "artifactHeading": "Rooftop Rush, build " + B8 + ".", "brandLabel": "@NikBearBrown",
      "artifactLines": ["Works: new hero, 2,500 px route, three web-zip towers, retries, replay.",
                        "Uncertain: is moving-cab timing fair to a first-time human? One cab phase was tuned to the test route.",
                        "Known defects: the zone banner can cover the hero mid-jump; the web is visual only.",
                        "Next: a checkpoint at Manhattan Heights (x = 1000)."]},
      [{"at": "0.1", "event": "verdict card"}, {"at": "0.25", "event": "line 1 working"}, {"at": "0.45", "event": "line 2 uncertain"},
       {"at": "0.65", "event": "line 3 limits"}, {"at": "0.85", "event": "line 4 next"}])},
 {"beat_id": "B14", "act": "HANDOFF",
  "role_note": "HANDOFF LAW: Your turn. Prompt read verbatim, then discussed. Signs off 'Liam, in for Bear.'",
  "narration_text": "Your turn. I extended walker-jumpman with a double jump that skyscrapers require. Read tuning dot g d and levels slash first steps dot json. One: compute the rise and reach of one jump, and of a jump plus an air jump. Two: list every landing that needs the air jump. Three: propose one checkpoint and write a test that proves it respawns correctly. It makes Claude do the arithmetic before it touches code, so you can check its math against your own playtest. Run it on your own level. Liam, in for Bear.",
  "shot": remotion("ClaudeComposerAsk", {
      "greeting": "Your turn.", "topic": TOPIC, "segment": "Your Walker Level",
      "command": "I extended walker-jumpman with a double jump that skyscrapers require. Read tuning.gd and levels/first_steps.json. (1) Compute the rise and reach of one jump, and of a jump plus an air jump. (2) List every landing that needs the air jump. (3) Propose one checkpoint and write a test that proves it respawns correctly.",
      "runningText": "paste this into Claude…", "folderLabel": "@NikBearBrown", "modelLabel": "Claude", "effortLabel": "High",
      "output": ["Reach table computed.", "Air-jump landings listed.", "Checkpoint test drafted: check it by playing."],
      "animateTyping": True},
      [{"at": "0.05", "event": "'Your turn.' greeting"}, {"at": "0.1", "event": "prompt types"}, {"at": "0.75", "event": "result lines"}])},
 {"beat_id": "B15", "act": "OUTRO", "kind": "outro_voice", "tail_hold_s": 1.0,
  "role_note": "OUTRO-LOCK: ClaudeTitleOutro, exact title, hardcoded @NikBearBrown, slug-seeded mascot, no subline, spoken never scored, 1 s silent tail.",
  "narration_text": TITLE + ". At Nik Bear Brown.",
  "shot": remotion("ClaudeTitleOutro", {"title": TITLE, "slug": SLUG},
      [{"at": "0.0", "event": "title card"}, {"at": "0.3", "event": "@NikBearBrown + mascot"}])},
]

GAMEPLAY_QC = {"full_bleed": True,
    "contrast_regions": [{"label": "HUD title and controls", "box": [0.02, 0.01, 0.71, 0.17]},
                         {"label": "SCRIPTED-INPUT CAPTURE label", "box": [0.726, 0.106, 0.968, 0.160]}],
    "contrast_reason": "Real engine footage fills the frame edge to edge by design (the game's own HUD bars and play area). "
                       "The essential text is the game HUD and the burned-in capture label; whole-frame average ink is dominated by the "
                       "sky/building art, not text. Pixels inspected in _qc/gameplay-slots.png and _qc/B06-hold.png."}
for b in beats:
    if b["shot"].get("type") == "GAMEPLAY":
        b["qc"] = GAMEPLAY_QC
    if b["beat_id"] == "B01":
        b["qc"] = {"sparse_by_design": True, "sparse_reason": "Hesitant-writer bookend: the overview types token by token, so mid-beat frames are mostly cream by design (EXECUTIVE-SUMMARY LAW)."}

sheet_path = R / "beat_sheet.json"
old = {}
if sheet_path.exists():
    for b in json.loads(sheet_path.read_text()).get("beats", []):
        old[b["beat_id"]] = b
for b in beats:
    b.setdefault("voice", "am_onyx"); b.setdefault("engine", "kokoro")
    prev = old.get(b["beat_id"])
    if prev and prev.get("narration_text") == b["narration_text"]:
        for k in ("audio_file", "actual_duration_s", "speech_duration_s", "render_duration_s", "action_duration_s", "hold_s"):
            if k in prev: b[k] = prev[k]
        if "rendered" in (prev.get("shot", {}).get("remotion") or {}):
            b["shot"]["remotion"]["rendered"] = prev["shot"]["remotion"]["rendered"]

sheet = {"metadata": {
    "title": TITLE, "slug": SLUG, "topic": TOPIC, "kind": "godot-walkthrough", "mode": "walker",
    "brand": "claude-liam", "register": "Teardown", "engine": "kokoro", "voice": "am_onyx", "voice_kokoro": "am_onyx",
    "palette": "claude", "style_preset": "claude", "ground": "#FAF9F5", "aspect_ratio": "16:9", "fit": "crop",
    "captions": False, "channel": "@NikBearBrown", "channel_title": "@NikBearBrown", "folderLabel": "@NikBearBrown",
    "greeting": "Hej, Liam", "greeting_note": "hello lexicon: Hej (Swedish). Wagwan is Bear-only.",
    "persona": "Liam (in for Bear)", "in_for_bear": True,
    "audience": "CSYE 7270 reviewers and makers extending walker-jumpman",
    "game": {"name": "walker-jumpman-shriram-a", "build_id": BUILD, "engine": "Godot 4.7.2.stable.official.ed1daf0bf",
             "starter": "https://github.com/nikbearbrown/walker-jumpman"},
    "source": "godot/ (source snapshot " + BUILD + "), capture/run-01.mp4, evidence/mechanics-*.json",
    "fps": 30},
  "beats": beats}
sheet_path.write_text(json.dumps(sheet, indent=1, ensure_ascii=False) + "\n")
print(f"wrote {sheet_path} · {len(beats)} beats")
