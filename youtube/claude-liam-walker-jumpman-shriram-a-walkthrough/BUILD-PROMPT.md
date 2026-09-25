# BUILD-PROMPT — rebuild this film end to end

Paste into Claude Code from the `walker-jumpman-shriram-a` repo root, with the Brutalist toolkit at
`../brutalist.art` and Godot 4.7.2 at `~/Downloads/Godot.app` (or edit `G=` below).

```text
Read ../brutalist.art/skills/make/godot-waikthrough/SKILL.md and its references in full, then rebuild
youtube/claude-liam-walker-jumpman-shriram-a-walkthrough in walker mode without changing the game:

1. python3 REEL/tools/source_snapshot.py .   → must print bb0f4ad4…cd61f7; if not, the game changed:
   stop and re-author the film for the new build instead of reusing this evidence.
2. rsync -a --exclude .godot godot/ REEL/capture-project/ (keep capture_driver.gd and the 4K
   project.godot override), then record:
   $G --path REEL/capture-project --script res://capture_driver.gd --resolution 3840x2160 \
      --write-movie "$PWD/REEL/capture/run-01.avi" --fixed-fps 30
   Require "CAPTURE OK", then transcode to capture/run-01.mp4 (libx264 crf 12, yuv420p, 30 fps).
3. Re-check every tick in CAPTURE.md against capture/run-01-inputs.jsonl; update beat clip ranges if any moved.
4. python3 REEL/tools/author_sheet.py; python3 ../brutalist.art/runtime/scripts/generate_audio_kokoro.py REEL
5. python3 REEL/tools/conform_timeline.py   (exact-frame gameplay, labeled holds, conformed audio)
6. python3 ../brutalist.art/runtime/scripts/remotion_scenes.py REEL --force
7. python3 REEL/tools/write_coverage.py && python3 REEL/tools/write_docs.py
8. ../brutalist.art/art godot-waikthrough --check REEL
9. ../brutalist.art/art final REEL --height 2160 --fps 30 --out REEL/exports/landscape
10. Visual QC: sample frames at 2 fps and at 15/50/85 % of every beat, read them, and log
    defects in REEL/_qc/REPORT.md. Watch the whole export with sound. Never publish.
```
