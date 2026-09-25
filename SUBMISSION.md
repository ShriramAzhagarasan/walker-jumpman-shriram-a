# SUBMISSION

- **Assignment:** Assignment 1 - Extend Walker Jumpman
- **Student:** Shriram Alagarasan (azhagarasan.s@northeastern.edu)
- **Project name:** walker-jumpman-shriram-a
- **GitHub repository/folder URL:** https://github.com/ShriramAzhagarasan/walker-jumpman-shriram-a
- **Submitted commit SHA:** [fill: the final commit]
- **Game-source revision shown in the film:** source snapshot `bb0f4ad453a25096bb04b84f1609338760328c0868e43e4dfbb8c09454cd61f7` (method: `youtube/claude-liam-walker-jumpman-shriram-a-walkthrough/tools/source_snapshot.py`). Git commit containing it: `1cbbb850b988188bb2e28377dd897c2ff93d460b` (later commits change docs/film records only, not `godot/`)
- **Godot version and operating system:** Godot 4.7.2.stable.official.ed1daf0bf · macOS (Apple M1 Pro)
- **Final film URL and filename:** [fill media-storage URL] · `claude-liam-walker-jumpman-shriram-a-walkthrough.mp4` (3840×2160, 236.9 s)
- **Final film SHA-256:** `95d5bce41859a049246d39290566955ad2fa322d9066f48a19203c7930f710c4`
- **Summary of my changes:** Spider-Man hero (new silhouette, same 18×28 collider). Level 960 → 2,500 px across three NYC zones. Three skyscrapers need a new web-zip air jump (jump strength unchanged). Spikes → parked and moving taxis. Death messages by cause. Animated villains (decorative). Tests updated and extended (29 mechanics + 9 keyboard checks pass). Brutalist godot-waikthrough film (walker mode).
- **Known limitations:** moving-taxi fairness is untested by humans, and one taxi phase was tuned to the test route; the web is visual only; the zone banner can cover the hero; the completion time covers the last attempt only; focus-loss pause is not shown in the film (unit-tested).

Verify before submitting: `python3 youtube/claude-liam-walker-jumpman-shriram-a-walkthrough/tools/source_snapshot.py .` must print the snapshot above, so the film depicts the submitted source.
