# CHECKS-REPORT — Rooftop Rush: Extending Walker Jumpman

16 SHOW / 0 justified-HOLD / 0 PUNT-flagged
(Gameplay beats hold their final frame only where narration outlasts the action. Each hold is labeled HELD FRAME on screen and noted in SHOTLIST.md; it is not a static-card beat.)

Teaching arc: FRAMEWORK ✓ | WORKED EXAMPLE ✓ | FALSIFIABILITY ✓ | SCAFFOLDED TASK ✓ | BOOKENDS ✓ | NO-SOURCE-NO-VERDICT ✓

- **Framework:** B01 (what was built) and B05 (the cause: 53 px jump vs 60–74 px towers, one air jump).
- **Worked example:** B06–B09. The same route played three ways: coyote/buffer, then no web-zip left (fails), then the clean run (succeeds).
- **Falsifiability:** B05 states a prediction ("without a web-zip left, the first tower is out of reach") before B07 shows it happening in the engine.
- **Scaffolded task:** B14, Your Turn. Compute the reach, list the air-jump landings, write a checkpoint test.
- **Bookends (walker mode):** B00 ClaudeComposerAsk, "Please use Walker to convert my game design document about…" (labeled an illustrative reconstruction) → B01 hesitant-writer summary → body → B13 Verdict → B14 Your Turn → B15 regular outro (ClaudeTitleOutro, @NikBearBrown, spoken title, no jingle).
- **No source, no verdict:** every verdict line maps to FACTCHECK.md rows (capture log, tests, source lines).

Assignment film requirements → beats:

| Requirement | Beat(s) |
|---|---|
| Starter, character concept, level extension | B00, B01, B04, B12 |
| Actual game played: new landings, failure/recovery, completion | B02, B03, B07 (failure), B08–B09 (3 new tower landings), B10 (completion + replay) |
| Cause and effect: source change → behavior | B05 (tuning.gd + level rows) → B07 (fails) / B08 (web-zip succeeds) |
| What was tested, what's uncertain, one next improvement | B11, B13 |
| Human and AI contributions; revision shown | B12 (source snapshot bb0f4ad4), B13 |
| Labels: reconstructed views, scripted captures, held frames | B00 topic line; burned SCRIPTED-INPUT CAPTURE label; HELD FRAME label; B04 test-harness note; B11 reconstructed terminal view |
