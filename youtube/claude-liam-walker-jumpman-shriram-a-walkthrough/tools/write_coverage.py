#!/usr/bin/env python3
"""Write coverage.json (godot-waikthrough contract, schema_version 1).

All times are seconds in capture/run-01.mp4 (= physics tick / 60, from
capture/run-01-inputs.jsonl). Hashes are computed from the actual bytes.
"""
import hashlib, json, subprocess, sys
from pathlib import Path

R = Path(__file__).resolve().parents[1]
REPO = R.parents[1]
sys.path.insert(0, str(Path(__file__).parent))
from source_snapshot import snapshot

build, _ = snapshot(REPO)
cap = R / 'capture/run-01.mp4'
cap_sha = hashlib.sha256(cap.read_bytes()).hexdigest()

def ev(beat, start, action, end, obs, riff):
    return {"capture": "run-01", "beat_id": beat, "start_s": start, "action_s": action, "end_s": end,
            "observation": obs, "riff": riff}

features = [
 {"id": "menu-start", "status": "implemented", "evidence": [ev("B02", 0.0, 2.50, 3.0,
   "Menu modal 'Spider-Man: Rooftop Rush'; Enter (InputEventAction confirm, tick 150) starts play.", "Enter starts; one key, no extra screens.")]},
 {"id": "run-and-jump", "status": "implemented", "evidence": [ev("B02", 2.6, 3.08, 3.9,
   "Holding right runs; jump at tick 185 lands on the small step.", "Movement tuning is the starter's; only the look changed.")]},
 {"id": "taxi-hazard-death", "status": "implemented", "evidence": [ev("B02", 3.5, 4.267, 4.70,
   "Player contacts the parked taxi at x=320.9; 'Watch the taxis! You landed on a cab full of civilians.' overlay; RETRIES 01.", "Spikes became cabs; the kill zone is the cab outline.")]},
 {"id": "auto-retry", "status": "implemented", "evidence": [ev("B03", 4.70, 4.833, 5.6,
   "0.57 s after contact the player respawns at x=64, RETRIES stays 01.", "Cheap retry: back in half a second.")]},
 {"id": "facing-left-right", "status": "implemented", "evidence": [ev("B03", 6.0, 6.35, 9.0,
   "move_left for 18 ticks: sprite mirrors and idles facing left; later faces right again.", "The whole drawing mirrors via one transform.")]},
 {"id": "pause-resume", "status": "implemented", "evidence": [ev("B03", 9.5, 9.833, 13.6,
   "Esc opens 'Take a breath.'; the timer and taxis freeze; Enter at tick 800 resumes.", "Pause freezes everything, timer included.")]},
 {"id": "manual-restart", "status": "implemented", "evidence": [ev("B03", 14.0, 14.667, 15.6,
   "R at tick 880 returns to the start; RETRIES stays 01 (not a death).", "Manual restart isn't counted as a death.")]},
 {"id": "coyote-time", "status": "implemented", "evidence": [ev("B06", 18.5, 19.0, 19.5,
   "Leaves the floor at tick 1136 without jumping; press at 1140 (4 ticks late, window 6) and the jump fires at 1142 (input log).", "Coyote time forgives a late press.")]},
 {"id": "jump-buffer", "status": "implemented", "evidence": [ev("B06", 19.8, 20.133, 20.45,
   "With the air jump spent, a press at tick 1208 while airborne fires a jump on landing at 1212 (buffer window 6).", "Buffer forgives an early press, once the web-zip is spent.")]},
 {"id": "skyscraper-needs-web-zip", "status": "implemented", "evidence": [ev("B07", 20.45, 21.133, 21.65,
   "With no air jump left, the ground jump hits the first tower's wall below its roof (y 246) and falls: 'Missed the landing'; RETRIES 02.", "53 px jump vs a 74 px tower: the source numbers predict this.")]},
 {"id": "fall-death", "status": "implemented", "evidence": [ev("B07", 20.8, 21.133, 21.65,
   "Falling below fall_y 430 triggers 'Missed the landing / Straight down onto the civilians below.'", "Falling and taxis give different messages.")]},
 {"id": "web-zip-double-jump", "status": "implemented", "evidence": [ev("B08", 25.3, 25.767, 26.6,
   "Second press in the air at tick 1546; web line from the wrist to the ceiling; lands on the glass tower (new landing 1).", "One air jump, visible as a web to the ceiling.")]},
 {"id": "zone-transitions", "status": "implemented", "evidence": [ev("B08", 24.5, 25.0, 27.0,
   "Crossing x=512 shows the 'Afternoon · 02 MIDTOWN CROSSING' banner and the sky blends to day; the banner overlaps the hero (observed defect).", "Zone banner informs but can cover the player.")]},
 {"id": "moving-taxis", "status": "implemented", "evidence": [ev("B09", 30.5, 31.5, 32.5,
   "Taxis patrol the Manhattan rooftops with headlights leading; the route passes between them.", "Traffic is timed off the attempt clock, so retries replay it.")]},
 {"id": "manhattan-skyscrapers", "status": "implemented", "evidence": [ev("B09", 28.8, 29.367, 30.3,
   "Web-zip at tick 1762 onto tower two (x 1328); again at tick 1961 onto tower three (x 1860).", "Two more landings that only the web-zip reaches.")]},
 {"id": "animated-villains", "status": "implemented", "evidence": [ev("B03", 5.0, 6.0, 9.0,
   "Vulture flaps across the Queens sky; Goblin and Doc Ock appear in later zones (decorative, no collision).", "Background characters animate but can't hurt you.")]},
 {"id": "finish-completion", "status": "implemented", "evidence": [ev("B10", 35.88, 36.40, 37.5,
   "Reaches the flag at x=2385 (tick 2184): 'You're Amazing, Spider-Man.' with this attempt's time and 2 retries.", "Timer covers the last attempt only.")]},
 {"id": "replay-mouse", "status": "implemented", "evidence": [ev("B10", 42.5, 43.40, 44.0,
   "Real cursor warped to the PLAY AGAIN button (HUD 319.6, 214.6) and left-clicked at tick 2604; fresh session at tick 2606, RETRIES 00.", "Replay resets the counters.")]},
 {"id": "main-menu", "status": "implemented", "evidence": [ev("B10", 45.0, 46.933, 48.9,
   "Esc then M (tick 2816) returns to the main menu modal.", "Back to the menu from pause.")]},
 # Implemented but NOT shown: an OS window-focus event the scripted capture cannot
 # produce honestly (unit test focus-loss-pauses covers it). Left as implemented with
 # no evidence, so the coverage check fails until shown or a human accepts a partial walkthrough.
 {"id": "focus-loss-pause", "status": "implemented", "note": "not demonstrated in the film; unit test focus-loss-pauses only", "evidence": []},
 {"id": "checkpoints", "status": "planned", "reason": "Next improvement named in the verdict; not built.", "evidence": []},
 {"id": "audio", "status": "planned", "reason": "The game has no sound; none is claimed or added.", "evidence": []},
]

cov = {"schema_version": 1,
       "game": {"name": "walker-jumpman-shriram-a", "build_id": build},
       "captures": {"run-01": {"path": "capture/run-01.mp4", "sha256": cap_sha, "build_id": build,
                               "method": "scripted-input", "input_log": "capture/run-01-inputs.jsonl"}},
       "features": features}
(R / 'coverage.json').write_text(json.dumps(cov, indent=1) + '\n')
print('coverage.json', build[:12], cap_sha[:12], len(features), 'features')
