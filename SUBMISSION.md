# SUBMISSION

- **Assignment:** Assignment 1 - Extend Walker Jumpman (late submission, 2026-09-25; revision of my earlier Canvas submission)
- **Student:** Shriram Alagarasan (azhagarasan.s@northeastern.edu)
- **Project name:** walker-jumpman-shriram-a
- **GitHub repository/folder URL:** https://github.com/ShriramAzhagarasan/walker-jumpman-shriram-a
- **Submitted commit SHA:** given in the Canvas submission note (a commit cannot contain its own SHA). It is the latest commit on `main`, and its only changes after `1cbbb85` are documentation and film records.
- **Game-source revision shown in the film:** source snapshot `bb0f4ad453a25096bb04b84f1609338760328c0868e43e4dfbb8c09454cd61f7` (method: `youtube/claude-liam-walker-jumpman-shriram-a-walkthrough/tools/source_snapshot.py`). Git commit containing it: `1cbbb850b988188bb2e28377dd897c2ff93d460b` (later commits change docs/film records only, not `godot/`)
- **Godot version and operating system:** Godot 4.7.2.stable.official.ed1daf0bf · macOS (Apple M1 Pro)
- **Final film URL and filename:** https://northeastern-my.sharepoint.com/:v:/g/personal/azhagarasan_s_northeastern_edu/IQAeSO04LvaESbmuwXkYTi0HAXkYAXgQbWnejsIEFEg9MSk?nav=eyJyZWZlcnJhbEluZm8iOnsicmVmZXJyYWxBcHAiOiJPbmVEcml2ZUZvckJ1c2luZXNzIiwicmVmZXJyYWxBcHBQbGF0Zm9ybSI6IldlYiIsInJlZmVycmFsTW9kZSI6InZpZXciLCJyZWZlcnJhbFZpZXciOiJNeUZpbGVzTGlua0NvcHkifX0&e=KBxtKp · `claude-liam-walker-jumpman-shriram-a-walkthrough.mp4` (3840×2160, 236.9 s)
- **Final film SHA-256:** `95d5bce41859a049246d39290566955ad2fa322d9066f48a19203c7930f710c4`
- **Summary of my changes:** Spider-Man hero (new silhouette, same 18×28 collider). Level 960 → 2,500 px across three NYC zones. Three skyscrapers need a new web-zip air jump (jump strength unchanged). Spikes → parked and moving taxis. Death messages by cause. Animated villains (decorative). Tests updated and extended (29 mechanics + 9 keyboard checks pass). Human playtest by me (about 100 runs; TEST-REPORT.md, FRICTIONAL.md Entry 7). Brutalist godot-waikthrough film (walker mode, 4K, scripted-input capture labeled on screen).
- **Known limitations:** the moving taxis felt fair to me once I learned their timing, but they are untested with other first-time players, and one taxi phase was tuned to the automated route. The zone banner covers Spider-Man during web-zips in Midtown and Manhattan (seen in the film capture and in my playtest; not fixed, so the film matches the build). The web is visual only. The completion time covers the last attempt only. The focus-loss pause is unit-tested but not shown in the film. The Brutalist type-check pre-gate was overridden for 4 documented false positives (`youtube/…/_qc/GATE-T-OVERRIDE.md`).

Verify before submitting: `python3 youtube/claude-liam-walker-jumpman-shriram-a-walkthrough/tools/source_snapshot.py .` must print the snapshot above, so the film depicts the submitted source.
