extends Control
var game: Node2D
const INK    := Color("e0e0e0")
const ACCENT := Color("CE1620")

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func text_at(text: String, position: Vector2, size_px: int = 14, color: Color = INK) -> void:
	draw_string(ThemeDB.fallback_font, position, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px, color)

func _draw() -> void:
	if not is_instance_valid(game):
		return
	var font := ThemeDB.fallback_font

	# ── TOP BAR ───────────────────────────────────────────────────────────────
	draw_rect(Rect2(0, 0, 640, 74), Color("090e1c"))
	draw_rect(Rect2(0, 0, 640, 3), ACCENT)
	text_at("WALKER / SPIDER-MAN", Vector2(22, 27), 18)
	text_at("ROOFTOP RUSH", Vector2(477, 27), 14, ACCENT)
	text_at("A/D or arrows: move     Space: jump (x2 in air)     R: retry     Esc: pause", Vector2(22, 50), 13, Color("666666"))
	draw_rect(Rect2(22, 63, 596, 3), Color("1a2540"))
	var progress: float = clampf((game.player.position.x - 64) / 2360, 0, 1)
	draw_rect(Rect2(22, 63, 596 * progress, 3), ACCENT)

	# ── BOTTOM BAR ────────────────────────────────────────────────────────────
	draw_rect(Rect2(0, 335, 640, 25), Color("090e1c"))
	draw_rect(Rect2(0, 358, 640, 2), ACCENT)
	text_at("No lives. Just another try.", Vector2(22, 353), 13, Color("666666"))
	text_at("RETRIES %02d     %04.1fs" % [game.deaths, game.elapsed], Vector2(440, 353), 13)

	# ── ANIMATED ZONE POPUP ───────────────────────────────────────────────────
	if game.zone_popup_time > 0.0 and game.cur_zone >= 0 and game.state == game.State.PLAYING:
		var t: float  = game.zone_popup_time
		var alpha: float
		var slide_x: float
		if t > 2.5:
			alpha   = (3.0 - t) / 0.5
			slide_x = (1.0 - alpha) * -300.0
		elif t < 0.5:
			alpha   = t / 0.5
			slide_x = 0.0
		else:
			alpha   = 1.0
			slide_x = 0.0
		var znames := ["QUEENS BRIDGE", "MIDTOWN CROSSING", "MANHATTAN HEIGHTS"]
		var ztimes := ["Morning  •  01", "Afternoon  •  02", "Night  •  03"]
		var zfont := ThemeDB.fallback_font
		draw_rect(Rect2(slide_x + 80, 128, 310, 60), Color(0.0, 0.0, 0.0, 0.88 * alpha))
		draw_rect(Rect2(slide_x + 80, 128, 5, 60), Color(0.878, 0.086, 0.125, alpha))
		draw_string(zfont, Vector2(slide_x + 92, 146), ztimes[game.cur_zone], HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.878, 0.086, 0.125, alpha))
		draw_string(zfont, Vector2(slide_x + 92, 165), znames[game.cur_zone], HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color(1.0, 1.0, 1.0, alpha))
		draw_string(zfont, Vector2(slide_x + 92, 182), "Spider-Man: Rooftop Rush", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.7, 0.7, 0.7, alpha * 0.7))

	if game.state == game.State.PLAYING:
		return

	# ── DEATH OVERLAY ─────────────────────────────────────────────────────────
	if game.state == game.State.DYING:
		draw_rect(Rect2(160, 122, 320, 72), Color("090e1c"))
		draw_rect(Rect2(160, 122, 320, 3), ACCENT)
		draw_string(font, Vector2(160, 150), game.death_reason, HORIZONTAL_ALIGNMENT_CENTER, 320, 21, ACCENT)
		draw_string(font, Vector2(160, 172), game.death_detail, HORIZONTAL_ALIGNMENT_CENTER, 320, 12, Color("bbbbbb"))
		draw_string(font, Vector2(160, 188), "Back at the start in a moment.", HORIZONTAL_ALIGNMENT_CENTER, 320, 10, Color("777777"))
		return

	# ── MENU / PAUSE / COMPLETE OVERLAY ──────────────────────────────────────
	# Semi-transparent overlay
	draw_rect(Rect2(0, 74, 640, 261), Color(0.0, 0.0, 0.0, 0.70))
	# Modal box — all text draws INSIDE mx..mx+mw so nothing overflows
	var mx := 140.0
	var mw := 360.0
	draw_rect(Rect2(mx, 100, mw, 172), Color("090e1c"))
	draw_rect(Rect2(mx, 100, mw, 4), ACCENT)

	var title  := "Spider-Man: Rooftop Rush"
	var detail := "Skyscrapers. Moving taxis. One flag. Be Amazing."
	var button := "ENTER  /  START"
	if game.state == game.State.PAUSED:
		title  = "Take a breath."
		detail = "R: restart attempt    M: main menu"
		button = "ENTER  /  RESUME"
	elif game.state == game.State.COMPLETE:
		title  = "You're Amazing, Spider-Man."
		detail = "%.1f seconds  /  %d retries" % [game.last_finish_time, game.deaths]
		button = "ENTER  /  PLAY AGAIN"

	# All text centered within modal bounds — guaranteed no overflow
	draw_string(font, Vector2(mx, 140), title,  HORIZONTAL_ALIGNMENT_CENTER, mw, 20, Color("ffffff"))
	draw_string(font, Vector2(mx, 166), detail, HORIZONTAL_ALIGNMENT_CENTER, mw, 12, Color("888888"))
	draw_string(font, Vector2(mx, 184), "Press Space again mid-air to web-zip up skyscrapers.", HORIZONTAL_ALIGNMENT_CENTER, mw, 10, Color("444444"))
	# Button
	draw_rect(Rect2(220, 198, 200, 34), ACCENT)
	draw_string(font, Vector2(220, 220), button, HORIZONTAL_ALIGNMENT_CENTER, 200, 13, Color("ffffff"))
