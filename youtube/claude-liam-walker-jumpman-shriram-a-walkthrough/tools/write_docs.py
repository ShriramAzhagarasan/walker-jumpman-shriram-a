#!/usr/bin/env python3
"""Generate SHOTLIST.md and RIFF.md from beat_sheet.json + coverage.json (no hand drift)."""
import json
from pathlib import Path

R = Path(__file__).resolve().parents[1]
sheet = json.loads((R / 'beat_sheet.json').read_text())
cov = json.loads((R / 'coverage.json').read_text())
md = sheet['metadata']

rows = ['# SHOTLIST — ' + md['title'], '',
        f"Build `{md['game']['build_id']}` · 3840×2160 · 30 fps · Liam (Kokoro am_onyx). Times are film seconds.", '',
        '| Beat | Act | Film in–out | Visual | Source / label | Hold |', '|---|---|---|---|---|---|']
t = 0.0
for b in sheet['beats']:
    d = b['actual_duration_s']; sh = b['shot']
    if sh.get('type') == 'GAMEPLAY':
        c = sh['capture']
        vis = f"capture/run-01.mp4 {c['start_s']:.2f}–{c['end_s']:.2f} s (native speed)"
        src = 'SCRIPTED-INPUT CAPTURE label burned in'
    elif sh.get('source') == 'remotion':
        vis = 'Remotion ' + sh['remotion']['pattern']
        src = (sh['remotion']['props'].get('source') or sh['remotion']['props'].get('topic') or 'Claude skin')
    else:
        vis = 'media/B04.png (engine close-ups)'
        src = 'labeled on card: test harness, not gameplay'
    hold = f"{b.get('hold_s', 0):.2f} s HELD FRAME" if b.get('hold_s') else '—'
    rows.append(f"| {b['beat_id']} | {b['act']} | {t:.2f}–{t + d:.2f} | {vis} | {src} | {hold} |")
    t += d
rows += ['', f'Total: {t:.2f} s.', '']
(R / 'SHOTLIST.md').write_text('\n'.join(rows))

by_beat = {}
for f in cov['features']:
    for e in f['evidence']:
        by_beat.setdefault(e['beat_id'], []).append((f['id'], e))
riff = ['# RIFF — ' + md['title'], '',
        'Riff pass over the actual capture (capture/run-01.mp4, scripted input, build '
        f"`{md['game']['build_id'][:12]}…`). Observations come from frames + the input log; "
        'interpretations name their source. A scripted route is not a human playtest; fun and fairness are not judged here.', '',
        '| Beat | Capture range | Visible observation | Interpretation (source) | Narration | Next experiment |', '|---|---|---|---|---|---|']
nexts = {'B02': 'Does a first-time player read the cab as a hazard before touching it?',
         'B03': 'Time how long players stay paused; is "Take a breath." enough context?',
         'B06': 'Try a 7-tick-late press: the unit test says it should fail.',
         'B07': 'Ask a player to predict whether the tower is reachable before trying.',
         'B08': 'Move the zone banner out of the play area and re-capture.',
         'B09': 'Play with the cab phases randomized; is the route still fair?',
         'B10': 'Show total session time as well as the last attempt.'}
for b in sheet['beats']:
    if b['shot'].get('type') != 'GAMEPLAY':
        continue
    c = b['shot']['capture']
    obs = ' / '.join(e['observation'] for _, e in by_beat.get(b['beat_id'], [])) or b['role_note']
    interp = ' / '.join(e['riff'] for _, e in by_beat.get(b['beat_id'], []))
    riff.append(f"| {b['beat_id']} | {c['start_s']:.2f}–{c['end_s']:.2f} s | {obs} | {interp} (source: game code + input log) | {b['narration_text']} | {nexts.get(b['beat_id'], '')} |")
riff += ['', '## Not shown', '',
         '- focus-loss pause: implemented (session.gd `_on_focus_lost`) but an OS focus event the scripted capture cannot produce honestly; only the unit test `focus-loss-pauses` covers it.', '']
(R / 'RIFF.md').write_text('\n'.join(riff))
print('wrote SHOTLIST.md, RIFF.md')
