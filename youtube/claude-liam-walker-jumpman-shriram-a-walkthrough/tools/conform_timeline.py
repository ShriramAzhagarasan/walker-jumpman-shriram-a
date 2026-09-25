#!/usr/bin/env python3
"""Conform audio and gameplay slots to exact 30 fps frame counts (no retiming).

For every beat:
  speech  = measured Kokoro mp3 (mp3/beat-<id>.mp3)
  audio   = lead_silence_s + speech (+ tail_hold_s) padded with silence -> mp3/conformed/<id>.wav
Gameplay beats (shot.type == GAMEPLAY):
  action  = exact frames [start_s*30, end_s*30) of capture/run-01.mp4, played at normal speed
  if the audio is longer, the final frame is held and labeled HELD FRAME;
  if the action is longer, the audio is padded with silence.
  Every frame carries the SCRIPTED-INPUT CAPTURE label -> media/<id>.mp4
All other beats: audio padded up to the next whole frame.
Writes actual_duration_s = frames/30 so compile.py's retime ratio is exactly 1.000000.
"""
import json, math, subprocess, sys
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

R = Path(__file__).resolve().parents[1]
FPS = 30
FONTS = Path('/Users/shriramalagarasan/Desktop/NortheasternUniversity/Fall2026/brutalist.art/runtime/fonts')
CAPTURE = R / 'capture/run-01.mp4'

def sh(*cmd):
    subprocess.run([str(c) for c in cmd], check=True)

def dur(path):
    out = subprocess.run(['ffprobe', '-v', 'error', '-show_entries', 'format=duration', '-of', 'csv=p=0', str(path)],
                         capture_output=True, text=True, check=True).stdout
    return float(out)

def font(name, size):
    return ImageFont.truetype(str(next(f for f in FONTS.rglob('*.ttf') if name in f.name)), size)

# Gameplay is reframed at 85 % inside the title-safe box (never cropped, never
# retimed); the label lives in a caption band under the footage, clear of gameplay.
FRAME_W, FRAME_H, FRAME_X, FRAME_Y = 3264, 1836, 288, 116
REFRAME = f"scale={FRAME_W}:{FRAME_H}:flags=lanczos,pad=3840:2160:{FRAME_X}:{FRAME_Y}:color=0x07080c"

def label_png(path, build8, held):
    im = Image.new('RGBA', (3840, 2160), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    y = FRAME_Y + FRAME_H + 22
    text = 'SCRIPTED-INPUT CAPTURE  ·  real engine run  ·  Godot 4.7.2 Movie Maker  ·  build ' + build8
    d.text((FRAME_X, y), text, font=font('Lato-Bold', 52), fill=(255, 255, 255, 255))
    if held:
        tag = 'HELD FRAME  ·  final frame of the action'
        f = font('Lato-Bold', 52)
        w = d.textlength(tag, font=f)
        d.rounded_rectangle((FRAME_X + FRAME_W - w - 40, y - 12, FRAME_X + FRAME_W, y + 70), 14, fill=(217, 119, 87, 255))
        d.text((FRAME_X + FRAME_W - w - 20, y), tag, font=f, fill=(255, 255, 255, 255))
    im.save(path)

def evidence_png(path, lines):
    """Input-log panel in native capture coordinates; it is scaled with the footage."""
    im = Image.new('RGBA', (3840, 2160), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    f_head, f_line = font('Lato-Bold', 58), font('PTMono-Regular', 52)
    w, h = 2330, 110 + 84 * (len(lines) - 1) + 40
    x0, y0 = 3840 - 60 - w, 1180   # right side: clear of the hero on this take
    d.rounded_rectangle((x0, y0, x0 + w, y0 + h), 26, fill=(6, 8, 16, 250), outline=(217, 119, 87, 255), width=5)
    for i, line in enumerate(lines):
        d.text((x0 + 40, y0 + 30 + i * 84), line, font=f_head if i == 0 else f_line, fill=(255, 255, 255, 255))
    im.save(path)

def main():
    sheet_path = R / 'beat_sheet.json'
    sheet = json.loads(sheet_path.read_text())
    build8 = sheet['metadata']['game']['build_id'][:8]
    (R / 'mp3/conformed').mkdir(parents=True, exist_ok=True)
    (R / '_qc/labels').mkdir(parents=True, exist_ok=True)
    label_png(R / '_qc/labels/live.png', build8, False)
    label_png(R / '_qc/labels/held.png', build8, True)
    report = []
    for b in sheet['beats']:
        bid = b['beat_id']
        speech_file = R / f'mp3/beat-{bid}.mp3'
        speech = dur(speech_file)
        lead = float(b.get('lead_silence_s', 0.0))
        tail = float(b.get('tail_hold_s', 0.0))
        need = lead + speech + tail
        shot = b.get('shot', {})
        if shot.get('type') == 'GAMEPLAY':
            cap = shot['capture']
            f0, f1 = round(cap['start_s'] * FPS), round(cap['end_s'] * FPS)
            action_frames = f1 - f0
            frames = max(action_frames, math.ceil(need * FPS - 1e-9))
            hold = frames - action_frames
            live = R / f'_qc/labels/{bid}-live.mp4'
            # Exact frame trim at native speed, reframed inside title-safe, band label under it.
            sh('ffmpeg', '-v', 'error', '-y', '-i', CAPTURE, '-i', R / '_qc/labels/live.png',
               '-filter_complex', f'[0:v]trim=start_frame={f0}:end_frame={f1},setpts=PTS-STARTPTS,{REFRAME}[g];[g][1:v]overlay=0:0,format=yuv420p[v]',
               '-map', '[v]', '-r', FPS, '-c:v', 'libx264', '-preset', 'medium', '-crf', '12', live)
            parts = [live]
            if hold:
                last = R / f'_qc/labels/{bid}-last.png'
                sh('ffmpeg', '-v', 'error', '-y', '-i', CAPTURE, '-vf', f'select=eq(n\\,{f1 - 1})', '-frames:v', '1', last)
                inputs = ['-loop', '1', '-framerate', FPS, '-i', last, '-i', R / '_qc/labels/held.png']
                graph = f'[0:v]{REFRAME}[g];[g][1:v]overlay=0:0,format=yuv420p[v]'
                if shot.get('hold_overlay'):
                    ev_png = R / f'_qc/labels/{bid}-evidence.png'
                    evidence_png(ev_png, shot['hold_overlay'])
                    inputs += ['-i', ev_png]
                    graph = f'[0:v][2:v]overlay=0:0,{REFRAME}[g];[g][1:v]overlay=0:0,format=yuv420p[v]'
                held = R / f'_qc/labels/{bid}-held.mp4'
                sh('ffmpeg', '-v', 'error', '-y', *inputs, '-filter_complex', graph, '-map', '[v]', '-frames:v', hold,
                   '-r', FPS, '-c:v', 'libx264', '-preset', 'medium', '-crf', '12', held)
                parts.append(held)
            lst = R / f'_qc/labels/{bid}.txt'
            lst.write_text(''.join(f"file '{p}'\n" for p in parts))
            sh('ffmpeg', '-v', 'error', '-y', '-f', 'concat', '-safe', '0', '-i', lst, '-c', 'copy', R / f'media/{bid}.mp4')
            got = int(subprocess.run(['ffprobe', '-v', 'error', '-count_frames', '-select_streams', 'v:0', '-show_entries',
                                      'stream=nb_read_frames', '-of', 'csv=p=0', str(R / f'media/{bid}.mp4')],
                                     capture_output=True, text=True, check=True).stdout.strip())
            assert got == frames, (bid, got, frames)
            b['action_duration_s'] = round(action_frames / FPS, 6)
            b['hold_s'] = round(hold / FPS, 6)
        else:
            frames = math.ceil(need * FPS - 1e-9)
        total = frames / FPS
        wav = R / f'mp3/conformed/{bid}.wav'
        delay = round(lead * 1000)
        sh('ffmpeg', '-v', 'error', '-y', '-i', speech_file, '-af',
           f'aresample=48000,aformat=channel_layouts=stereo,adelay={delay}|{delay},apad',
           '-t', f'{total:.6f}', '-ar', '48000', '-c:a', 'pcm_s16le', wav)
        b['speech_duration_s'] = round(speech, 3)
        b['audio_file'] = f'mp3/conformed/{bid}.wav'
        b['actual_duration_s'] = total
        b['render_duration_s'] = total
        if (shot.get('remotion') or {}).get('props') is not None and shot['remotion']['pattern'] in ('BrutalistHesitantWriter', 'WalkerGodotSetup'):
            shot['remotion']['props']['durationSeconds'] = total
        report.append((bid, frames, round(total, 3), round(speech, 2), b.get('hold_s', '')))
    sheet_path.write_text(json.dumps(sheet, indent=1, ensure_ascii=False) + '\n')
    for row in report:
        print(*row)
    print('total', round(sum(r[2] for r in report), 3), 's')

if __name__ == '__main__':
    main()
