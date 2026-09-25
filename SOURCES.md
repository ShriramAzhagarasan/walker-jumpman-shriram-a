# SOURCES — walker-jumpman-shriram-a

## Starter

nikbearbrown/walker-jumpman (https://github.com/nikbearbrown/walker-jumpman)
Godot 4.7.2 · GDScript · original author: Nik Bear Brown
Used as the base for all game mechanics, level loading, session state machine, HUD, and test infrastructure.

## Assets

All visual drawing is original Godot vector drawing using `draw_rect`, `draw_circle`, `draw_line`, `draw_arc`, `draw_polygon`, and `draw_colored_polygon`. No external sprites, textures, fonts, or sound files were imported. The fallback engine font (`ThemeDB.fallback_font`) is the Godot engine built-in.

## Tools and AI

**Claude Code (Anthropic)** — AI pair programmer used for:
- Reading and summarizing the starter codebase
- Planning the Spider-Man character geometry and verifying jump feasibility with physics calculations
- Generating the `_draw()` replacement for `player.gd`
- Extending `first_steps.json`, updating `session.gd` drawing code, `route_driver.gd`, `test_game.gd`, and `hud.gd`
- Writing CHANGE-BRIEF.md, TEST-REPORT.md, FRICTIONAL.md, SOURCES.md
- Redrawing Spider-Man, Vulture, Green Goblin and Doctor Octopus as outlined vector characters (`player.gd`, `features/villains/villains.gd`), reviewed through rendered close-ups (`tests/capture_art.gd` → `evidence/art/`)
- Adding the web-zip double jump (web line anchored to the play-area ceiling), skyscraper platforms, moving taxis, and taxi/civilian death messages; re-tuning the route driver and tests

**Human (Shriram Alagarasan)** decided:
- Spider-Man as the character concept
- "Manhattan Rooftops" as the extension theme
- Review and approval of each proposed change before application
- Playtesting the final result and recording observations in TEST-REPORT.md

## References

Spider-Man character design: geometric interpretation only — no copyrighted art reproduced. Colors (#CE1620, #003790) are standard Spider-Man palette references used as a recognizable concept, drawn entirely from primitives.

## Film (Brutalist godot-waikthrough, walker mode)

- **Toolkit:** Brutalist (`nikbearbrown/brutalist.art`, course-provided), skill `skills/make/godot-waikthrough` (read in full with riff, ai-explainer, your-turn, OUTRO-LOCK). Downloaded as a ZIP because git is broken on this machine.
- **Gameplay:** the real game, recorded with Godot 4.7.2 Movie Maker from an isolated harness copy (`youtube/claude-liam-walker-jumpman-shriram-a-walkthrough/capture-project/`). Scripted input, labeled on screen. See that folder's `CAPTURE.md`.
- **Narration:** Kokoro-82M (`kokoro-onnx`, Apache-2.0), voice `am_onyx` ("Liam, in for Bear"). Local and free; no cloning, no paid TTS.
- **Scenes:** Remotion components shipped with the toolkit (ClaudeComposerAsk, BrutalistHesitantWriter, ClaudeCodeBeat, WalkerGodotSetup, ClaudeVerdictArtifact, ClaudeTitleOutro).
- **Fonts:** EB Garamond, Lato, PT Mono (SIL OFL, bundled with the toolkit).
- **No generative images, video or music.** The game has no audio, and none was added.

| Film part | Human (Shriram) | AI (Claude Code) |
|---|---|---|
| Decision to make the film, and its requirements | ✓ | — |
| Capture driver, route, retries shown | reviews | ✓ wrote and ran |
| Script, beat sheet, fact-check, prompts | reviews and approves | ✓ drafted |
| Narration audio | approves the voice | ✓ generated (Kokoro) |
| Render and frame QC | must watch the final export | ✓ rendered + frame QC |
| Fun, fairness, feel | ✓ judges (playtest) | does not judge |
