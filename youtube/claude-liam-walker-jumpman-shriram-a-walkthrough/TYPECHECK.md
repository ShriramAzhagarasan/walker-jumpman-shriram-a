# TYPECHECK.md — GATE T

Reel: `claude-liam-walker-jumpman-shriram-a-walkthrough`  |  Checked: 2026-09-25T00:09  |  Overall: **FAIL**  |  Beats checked: 16  |  FAILs: 4

Spec: `skills/make/kerning/reference/type-spec.md` §8.  Floor: 1.9% frame-height.  Contrast: 4.5:1 WCAG.  Kern threshold: 3.5× expected advance.  Wordy budget: 2 elements.

> **§8.7–§8.9 PLACEHOLDER / TRUNCATION — GATE BLOCKED:**
> Every item below must be fixed before `./art run` or `./art final`.
> Labels must be authored short phrases (2–5 words). Subs must add something real
> (≤8 words) or be omitted. 'see narration' and truncated strings must not reach
> a rendered surface.

> - §8.12b [B05/title] doubled-title: 'tuning.gd + first_steps.json (actual lines, excerp' has no file extension — ClaudeCodeBeat echoes the full title as the language badge. Use a filename (e.g. 'analysis.py') or fix the content to real code

| beat | lane | polarity | worst finding | status | fix |
|------|------|----------|---------------|--------|-----|
| B00 | ? | light | min-size §8.1: hand-drawn pattern (ClaudeComposerAsk) — §8.1 hachure/crossbar fragments ar… | PASS | — |
| B01 | ? | light | min-size §8.1: min text-run height 50px >= floor 41px | PASS | — |
| B02 | ? | dark | contrast-local §8.3b: per-blob contrast 1.78:1 < 3.0:1 — text unreadable on actual local b… | **FAIL** | Use INK on cream; add backing plate under accent text |
| B03 | ? | dark | min-size §8.1: min text-run height 42px >= floor 41px (individual-char fallback at 2×) | PASS | — |
| B04 | ? | — | no video | SKIP | — |
| B05 | ? | light | card-clip §8.13: §8.13 text blob touches card right boundary (col 3567 vs card_right 3567,… | **FAIL** | — |
| B06 | ? | dark | contrast-local §8.3b: per-blob contrast 2.75:1 < 3.0:1 — text unreadable on actual local b… | **FAIL** | Use INK on cream; add backing plate under accent text |
| B07 | ? | dark | contrast-local §8.3b: per-blob contrast 2.75:1 < 3.0:1 — text unreadable on actual local b… | **FAIL** | Use INK on cream; add backing plate under accent text |
| B08 | ? | dark | min-size §8.1: min text-run height 68px >= floor 41px | PASS | — |
| B09 | ? | dark | min-size §8.1: min text-run height 56px >= floor 41px | PASS | — |
| B10 | ? | dark | min-size §8.1: min text-run height 42px >= floor 41px (individual-char fallback at 2×) | PASS | — |
| B11 | ? | light | no-wordy-card §8.5: no prose payload found | PASS | — |
| B12 | ? | light | no-wordy-card §8.5: no prose payload found | PASS | — |
| B13 | ? | light | min-size §8.1: hand-drawn pattern (ClaudeVerdictArtifact) — §8.1 hachure/crossbar fragment… | PASS | — |
| B14 | ? | light | min-size §8.1: hand-drawn pattern (ClaudeComposerAsk) — §8.1 hachure/crossbar fragments ar… | PASS | — |
| B15 | ? | light | min-size §8.1: min text-run height 43px >= floor 41px | PASS | — |

---

## Failures requiring action before cut

### SWEEP GATES §8.7–§8.12b (placeholder / truncation / code-card)

- **§8.12b [B05/title] doubled-title: 'tuning.gd + first_steps.json (actual lines, excerp' has no file extension — ClaudeCodeBeat echoes the full title as the language badge. Use a filename (e.g. 'analysis.py') or fix the content to real code**

**Fix:** §8.7–§8.9: rewrite flagged labels/subs to authored words. §8.12: replace prose-comment code beat with FormACard or ClaudeVerdictArtifact. §8.12b: give ClaudeCodeBeat a real filename title (e.g. 'analysis.py').

### B02 (?)
- **contrast-local §8.3b**: per-blob contrast 1.78:1 < 3.0:1 — text unreadable on actual local background (blob@(962,1231)–(1031,1277) fg≈(204, 112, 76) bg≈(144, 79, 55)); move label off its background or change text color
- **Fix:** Use INK on cream; add backing plate under accent text

### B05 (?)
- **card-clip §8.13**: §8.13 text blob touches card right boundary (col 3567 vs card_right 3567, tol=4px) — text is clipped inside the card; reduce font or shorten the code line

### B06 (?)
- **contrast-local §8.3b**: per-blob contrast 2.75:1 < 3.0:1 — text unreadable on actual local background (blob@(1158,503)–(1535,715) fg≈(171, 190, 212) bg≈(61, 110, 171)); move label off its background or change text color
- **Fix:** Use INK on cream; add backing plate under accent text

### B07 (?)
- **contrast-local §8.3b**: per-blob contrast 2.75:1 < 3.0:1 — text unreadable on actual local background (blob@(799,503)–(1176,715) fg≈(171, 190, 212) bg≈(60, 110, 171)); move label off its background or change text color
- **Fix:** Use INK on cream; add backing plate under accent text

---

## Check summary

| Check | Beats checked | FAILs |
|-------|---------------|-------|
| no-wordy-card §8.5 | 3 | 0 |
| min-size §8.1 | 15 | 0 |
| overflow §8.2 | 15 | 0 |
| contrast §8.3 | 15 | 0 |
| contrast-local §8.3b | 15 | 3 |
| bbox-overlap §8.6b | 15 | 0 |
| card-clip §8.13 | 15 | 1 |
| kerning §8.4 | 0 | 0 |
| redundancy §8.10 (advisory) | 2 | 0 (advisory — no exit effect) |

---

*GATE T: any FAIL blocks `./art run` and `./art final`. Fix the flagged beats and re-run `scripts/type_check.py` until green.*
