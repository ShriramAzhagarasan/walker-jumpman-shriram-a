#!/usr/bin/env python3
"""Compose media/B04.png: engine-rendered close-ups (tests/capture_art.gd) on the
Claude cream stage. Crops are native pixels or downscales only — never upscaled."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
R = Path(__file__).resolve().parents[1]
FONTS = Path('/Users/shriramalagarasan/Desktop/NortheasternUniversity/Fall2026/brutalist.art/runtime/fonts')
def font(name, size):
    for f in FONTS.rglob('*.ttf'):
        if name.lower() in f.name.lower():
            return ImageFont.truetype(str(f), size)
    raise SystemExit(f'font {name} missing')
serif = font('EBGaramond', 92); ui = font('Lato-Regular', 44); ui_b = font('Lato-Bold', 50); small = font('Lato-Regular', 38)
CREAM, INK, SPARK, BORDER = '#FAF9F5', '#3D3929', '#D97757', '#E8E4D8'
W, H = 3840, 2160
sheet = Image.new('RGB', (W, H), CREAM)
d = ImageDraw.Draw(sheet)
d.text((192, 110), 'Same collider, new silhouette.', font=serif, fill=INK)
d.text((192, 245), 'Engine-rendered close-ups from tests/capture_art.gd (camera zoomed in a test harness; not gameplay) · build bb0f4ad4', font=small, fill='#6B6755')
def panel(img_name, box, crop_size, center, label, scale=1.0):
    im = Image.open(R / 'evidence/art' / img_name).convert('RGB')
    if scale != 1.0:
        im = im.resize((round(im.width * scale), round(im.height * scale)), Image.LANCZOS)
    cx, cy = center(im)
    cw, ch = crop_size
    im = im.crop((cx - cw // 2, cy - ch // 2, cx + cw // 2, cy + ch // 2))
    x, y = box
    d.rounded_rectangle((x - 6, y - 6, x + cw + 6, y + ch + 6), 18, outline=BORDER, width=6)
    sheet.paste(im, (x, y))
    d.text((x, y + ch + 22), label, font=ui_b, fill=INK)
mid = lambda im: (im.width // 2, im.height // 2)
cw, gap, x0 = 1090, 64, 212   # stays inside the 5% title-safe inset (x 192–3648)
for i, (n, lab) in enumerate([('spidey-run.png', 'Run · stride + arm swing'), ('spidey-jump.png', 'Jump · far arm fires the web'), ('spidey-idle.png', 'Idle · facing right')]):
    panel(n, (x0 + i * (cw + gap), 360), (cw, 900), mid, lab, scale=0.62)
for i, (n, lab) in enumerate([('vulture.png', 'Vulture (decorative, no collision)'), ('goblin.png', 'Green Goblin (decorative)'), ('doc-ock.png', 'Doctor Octopus (decorative)')]):
    panel(n, (x0 + i * (cw + gap), 1390), (cw, 500), mid, lab, scale=0.33)
d.text((W - 212 - 330, H - 190), '@NikBearBrown', font=ui, fill='#8B8878')
out = R / 'media/B04.png'
sheet.save(out)
print(out, sheet.size)
