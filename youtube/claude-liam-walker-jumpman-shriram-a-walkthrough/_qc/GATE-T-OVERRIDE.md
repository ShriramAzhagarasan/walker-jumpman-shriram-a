# GATE T override — documented, not silent

`./art final` runs `type_check.py` (GATE T) before compiling. On this reel it reports 4 FAILs
(TYPECHECK.md, 2026-09-25T00:09). All four were inspected on the actual pixels and are
false positives of a typography heuristic, not film defects:

| Beat | Flag | Blob (px, fg / bg) | What it actually is |
|---|---|---|---|
| B02 | contrast-local 1.78:1 | (962,1231)–(1031,1277), (204,112,76) / (144,79,55) | Queens backdrop: sun-halo glow over brownstone brick (game art, no text) |
| B06 | contrast-local 2.75:1 | (1158,503)–(1535,715), (171,190,212) / (61,110,171) | Midtown sky: semi-transparent white clouds (game art) |
| B07 | contrast-local 2.75:1 | (799,503)–(1176,715), same colours | Same clouds, later camera position |
| B05 | card-clip at col 3567 | card right boundary | Stock ClaudeCodeBeat layout (language chip / edge); no code line is clipped (frame inspected) |

The fix TYPECHECK suggests ("Use INK on cream; add backing plate") does not apply to game artwork.
Changing the game's clouds or sky to satisfy the heuristic would change the game for the film, which the
assignment forbids. `type_check.py` has no per-beat declaration for real footage (its exemptions
are hard-coded by Remotion pattern). The toolkit also forbids loosening validators or relabeling gameplay
as a source report. The validator was **not** edited.

Decision (Shriram, 2026-09-25): compile with `runtime/scripts/compile.py` directly, i.e. the same
command `./art final` runs after GATE T. Every other gate still runs: paperwork (FACTCHECK/SHOTLIST/PROMPTS),
beat lint, shape gate, approvals, no slates, audio presence/duration, full decode, and final-frame QC with the
per-beat `qc` declarations recorded in beat_sheet.json.
