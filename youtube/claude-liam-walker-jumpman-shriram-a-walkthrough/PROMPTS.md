# PROMPTS — Rooftop Rush walkthrough

## On-screen prompts (what the viewer sees)

**B00, Walker ask. ILLUSTRATIVE RECONSTRUCTION, not a transcript** (labeled on screen):

> Please use Walker to convert my game design document about Spider-Man: Rooftop Rush, an extension of the walker-jumpman starter with a new hero, three New York zones, skyscrapers and moving taxis, into a playable Godot project.

The real work happened over many smaller Claude Code requests (below). The skill's walker mode requires this opening pattern; it is never presented as history.

**B14, Your Turn** (read aloud verbatim, then discussed):

> I extended walker-jumpman with a double jump that skyscrapers require. Read tuning.gd and levels/first_steps.json. (1) Compute the rise and reach of one jump, and of a jump plus an air jump. (2) List every landing that needs the air jump. (3) Propose one checkpoint and write a test that proves it respawns correctly.

## Human requests that shaped this revision (Shriram → Claude Code)

Paraphrased from the session, with the substance kept:

1. Replace the villain and Spider-Man art ("everyone looks really bad") with recognisable Green Goblin, Doctor Octopus, Vulture and Spider-Man.
2. Add real skyscrapers you can land on, with a "2x jump mechanism" for them.
3. Make the web go up and touch the ceiling instead of a short arc.
4. The taxi death message said "spikes"; it should say taxis and that you landed on civilians.
5. Add taxis moving over nearby and far ranges, "so that we have more chances to fail".
6. Make the Brutalist godot-waikthrough film with the walker modifier.

## Production prompts (Claude Code, inside this build)

- Skill instructions read in full: `brutalist.art/skills/make/godot-waikthrough/SKILL.md`, `references/capture-and-coverage.md`, `skills/make/riff/SKILL.md`, `skills/make/ai-explainer/SKILL.md`, `skills/make/your-turn/SKILL.md`, `OUTRO-LOCK.md`, `RENDER-TARGETS.md`, `docs/PIPELINE-SAFETY.md`.
- Narration voice: local Kokoro `am_onyx` (Liam, in for Bear). No paid TTS, no cloning, no music, no game sounds (the game has none).
- No generative images or video were used. Every visual is the real engine capture, engine-rendered stills, or Remotion scenes from the toolkit library.
