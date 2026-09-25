# Final export review (Claude Code) — claude-liam-walker-jumpman-shriram-a-walkthrough.mp4

- File: `exports/landscape/claude-liam-walker-jumpman-shriram-a-walkthrough.mp4` · SHA-256 `95d5bce41859a049246d39290566955ad2fa322d9066f48a19203c7930f710c4` (matches `.verified.json`, status ready)
- Probe: H.264 3840×2160, 30 fps, 7107 frames, 236.9 s; AAC audio; decodes fully (compile.py verify_output)
- Gate V (final_frame_check): 32 frames · BLOCKER 0 · MAJOR 0 (per-beat qc declarations in beat_sheet.json, with reasons)
- GATE T: 4 FAILs, all inspected false positives; compiled without the pre-check. See GATE-T-OVERRIDE.md
- Coverage (`./art godot-waikthrough --check`): all captures, hashes, dimensions and intervals valid. It FAILs only on
  `focus-loss-pause` (implemented, not shown). The film therefore does **not** claim a complete walkthrough.
- Frame review: 48 frames (15/50/85 % of every beat) in `_qc/review/contact-all.png`, read by Claude Code. Beat order is B00→B15.
  B01's correction lands. Gameplay is inside title-safe with the SCRIPTED-INPUT caption band on every gameplay frame, and HELD FRAME tags on holds.
  The B06 input-log panel does not cover the hero. The outro is ClaudeTitleOutro with the exact title and @NikBearBrown.
- Not verifiable by Claude: whether the narration sounds intelligible and natural, and whether the film is watchable as a whole.
  **Shriram must watch the complete export with sound before submitting** (the skill requires watching the final export).
