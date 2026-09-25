extends Node2D

const Player = preload("res://features/player/player.gd")
const Villains = preload("res://features/villains/villains.gd")
const Hud = preload("res://ui/hud.gd")
const TAXI_SIZE := Vector2(24, 16)
## Solid outline of the cab (inside its 24x16 box): contact means a crash.
const TAXI_SHAPE := [Vector2(2, 16), Vector2(2, 8), Vector2(6, 6.5), Vector2(8.5, 1.5), Vector2(16, 1.5), Vector2(19, 6.5), Vector2(22.5, 8), Vector2(22.5, 16)]
enum State { MENU, PLAYING, PAUSED, DYING, COMPLETE }

## Draws via a Callable so static scenery is painted once and cached by the
## canvas, while villains and taxis repaint each frame in the right layer order.
class Painter extends Node2D:
	var paint: Callable
	func _draw() -> void:
		paint.call(self)

var state: State = State.MENU
var player: CharacterBody2D
var camera: Camera2D
var hud: Control
var level: Dictionary
var hazard_areas: Array[Area2D] = []
var taxi_areas: Array[Area2D] = []
var movers: Array = []            # [{area, from, to, top, period, phase, dir}]
var goal: Area2D
var deaths: int = 0
var elapsed: float = 0.0
var anim_time: float = 0.0
var retry_remaining: float = 0.0
var death_reason: String = ""
var death_detail: String = ""
var last_finish_time: float = 0.0
var test_mode: bool = false
var contact_settle_ticks: int = 0
var cur_zone: int = -1
var zone_popup_time: float = 0.0
var villain_layer: Painter
var taxi_layer: Painter

# Sky gradient stops per zone (top of world, HUD edge, mid, horizon).
var SKY := [
	[Color("24163f"), Color("3b2455"), Color("d0603f"), Color("f7b267")],   # Queens morning
	[Color("1d4f93"), Color("2d68b0"), Color("5b9fd6"), Color("a8d4ef")],   # Midtown afternoon
	[Color("03060f"), Color("060c1c"), Color("0f1a36"), Color("22305a")],   # Manhattan night
]
const SKY_Y := [-220.0, 74.0, 210.0, 345.0]

func _ready() -> void:
	process_physics_priority = 10
	level = JSON.parse_string(FileAccess.get_file_as_string("res://levels/first_steps.json"))
	_setup_input()
	for entry in level.solids:
		_add_solid(Rect2(entry[0], entry[1], entry[2], entry[3]))
	_add_solid(Rect2(-32, 0, 32, 430))
	_add_solid(Rect2(level.width, 0, 32, 430))
	_add_painter(_paint_backdrop)
	villain_layer = _add_painter(_paint_villains)
	_add_painter(_paint_rooftops)
	taxi_layer = _add_painter(_paint_taxis)
	for entry in level.hazards:
		var area := _add_area(Rect2(entry[0], entry[1], entry[2], entry[3]), 8, true)
		hazard_areas.append(area)
		taxi_areas.append(area)
	for m in level.get("moving_taxis", []):
		var area := _add_area(Rect2(Vector2(m.from, m.top - TAXI_SIZE.y), TAXI_SIZE), 8, true)
		hazard_areas.append(area)
		taxi_areas.append(area)
		movers.append({"area": area, "from": float(m.from), "to": float(m.to), "top": float(m.top), "period": float(m.period), "phase": float(m.phase), "dir": 1.0})
	_update_movers()
	var f: Array = level.finish
	goal = _add_area(Rect2(f[0], f[1], f[2], f[3]), 16, false)
	player = Player.new()
	add_child(player)
	player.reset_at(Vector2(level.spawn[0], level.spawn[1]))
	camera = Camera2D.new()
	camera.position = Vector2(320, 180)
	add_child(camera)
	var layer := CanvasLayer.new()
	add_child(layer)
	hud = Hud.new()
	hud.game = self
	layer.add_child(hud)
	get_window().focus_exited.connect(_on_focus_lost)

func _add_painter(paint: Callable) -> Painter:
	var p := Painter.new()
	p.paint = paint
	add_child(p)
	return p

func _setup_input() -> void:
	var actions := {"move_left": [KEY_A, KEY_LEFT], "move_right": [KEY_D, KEY_RIGHT], "jump": [KEY_SPACE], "pause": [KEY_ESCAPE, KEY_P], "restart": [KEY_R], "confirm": [KEY_ENTER], "menu": [KEY_M]}
	for action in actions:
		if InputMap.has_action(action):
			continue
		InputMap.add_action(action)
		for key in actions[action]:
			var event := InputEventKey.new()
			event.physical_keycode = key
			InputMap.action_add_event(action, event)

func _add_solid(rect: Rect2) -> void:
	var body := StaticBody2D.new()
	body.position = rect.position + rect.size / 2
	body.collision_layer = 1
	body.collision_mask = 2
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	var collision := CollisionShape2D.new()
	collision.shape = shape
	body.add_child(collision)
	add_child(body)

func _add_area(rect: Rect2, layer: int, taxi: bool) -> Area2D:
	var area := Area2D.new()
	area.position = rect.position
	area.collision_layer = layer
	area.collision_mask = 2
	if taxi:
		# Exact cab silhouette scaled into the hazard box; no oversized invisible box.
		var poly := CollisionPolygon2D.new()
		var pts := PackedVector2Array()
		for p in TAXI_SHAPE:
			pts.append(p * rect.size / TAXI_SIZE)
		poly.polygon = pts
		area.add_child(poly)
	else:
		var collision := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = rect.size
		collision.shape = shape
		collision.position = rect.size / 2.0
		area.add_child(collision)
	add_child(area)
	return area

## Taxis ease back and forth between `from` and `to`, driven by attempt time
## so every retry replays the same traffic pattern.
func _update_movers() -> void:
	for m in movers:
		var w: float = TAU * (elapsed / m.period + m.phase)
		var u: float = 0.5 - 0.5 * cos(w)
		var area: Area2D = m.area
		area.position.x = lerpf(m.from, m.to - TAXI_SIZE.x, u)
		m.dir = 1.0 if sin(w) >= 0.0 else -1.0

func start_session() -> void:
	if state == State.PLAYING:
		return
	deaths = 0
	restart_attempt()

func restart_attempt() -> void:
	state = State.PLAYING
	elapsed = 0.0
	retry_remaining = 0.0
	_update_movers()
	# Area2D overlaps are physics-step snapshots. Discard pre-teleport contacts
	# until the broadphase has observed the reset, preventing a phantom second death.
	contact_settle_ticks = 2
	player.reset_at(Vector2(level.spawn[0], level.spawn[1]))
	player.enabled = true
	camera.position = Vector2(320, 180)

func set_paused(value: bool) -> void:
	if value and state == State.PLAYING:
		state = State.PAUSED
		player.enabled = false
	elif not value and state == State.PAUSED:
		state = State.PLAYING
		player.enabled = true
		player.require_jump_release = true
		player.jump_request_tick = -1000

func _on_focus_lost() -> void:
	if not test_mode:
		set_paused(true)

func resolve_contacts(fatal: bool, finished: bool) -> void:
	if state != State.PLAYING:
		return
	if fatal:
		state = State.DYING
		deaths += 1
		retry_remaining = 0.55
		player.enabled = false
		player.velocity = Vector2.ZERO
	elif finished:
		state = State.COMPLETE
		last_finish_time = elapsed
		player.enabled = false
		player.velocity = Vector2.ZERO

func _process(delta: float) -> void:
	anim_time += delta
	villain_layer.queue_redraw()
	taxi_layer.queue_redraw()

func _physics_process(delta: float) -> void:
	if state == State.DYING:
		retry_remaining -= delta
		if retry_remaining <= 0:
			restart_attempt()
	elif state == State.PLAYING:
		elapsed += delta
		_update_movers()
		var new_zone := 0
		if player.position.x >= 1000:
			new_zone = 2
		elif player.position.x >= 512:
			new_zone = 1
		if new_zone != cur_zone:
			cur_zone = new_zone
			zone_popup_time = 3.0
		zone_popup_time = maxf(0.0, zone_popup_time - delta)
		var fell := player.position.y > float(level.fall_y)
		var hit_taxi := false
		for hazard in hazard_areas:
			hit_taxi = hit_taxi or hazard.overlaps_body(player)
		if hit_taxi:
			death_reason = "Watch the taxis!"
			death_detail = "You landed on a cab full of civilians."
		elif fell:
			death_reason = "Missed the landing"
			death_detail = "Straight down onto the civilians below."
		if contact_settle_ticks > 0:
			contact_settle_ticks -= 1
		else:
			resolve_contacts(fell or hit_taxi, goal.overlaps_body(player))
		camera.position.x = clampf(player.position.x + 100, 320, float(level.width) - 320)
	if is_instance_valid(hud):
		hud.queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.echo:
		return
	if event.is_action_pressed("confirm"):
		if state in [State.MENU, State.COMPLETE]:
			start_session()
		elif state == State.PAUSED:
			set_paused(false)
	elif event.is_action_pressed("pause"):
		set_paused(state != State.PAUSED)
	elif event.is_action_pressed("restart") and state in [State.PLAYING, State.PAUSED, State.DYING]:
		restart_attempt()
	elif event.is_action_pressed("menu") and state in [State.PAUSED, State.COMPLETE]:
		state = State.MENU
		player.enabled = false
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if Rect2(220, 198, 200, 34).has_point(hud.get_local_mouse_position()):
			if state in [State.MENU, State.COMPLETE]:
				start_session()
			elif state == State.PAUSED:
				set_paused(false)

# ── ZONES ─────────────────────────────────────────────────────────────────
## Continuous zone index (0 Queens .. 2 Manhattan) with soft cross-fades.
func zone_weight(x: float) -> float:
	if x < 430.0:
		return 0.0
	if x < 600.0:
		return smoothstep(430.0, 600.0, x)
	if x < 900.0:
		return 1.0
	if x < 1080.0:
		return 1.0 + smoothstep(900.0, 1080.0, x)
	return 2.0

func _sky(zw: float, stop: int) -> Color:
	var z := mini(int(floor(zw)), 1)
	return SKY[z][stop].lerp(SKY[z + 1][stop], clampf(zw - z, 0.0, 1.0))

func _zone_of(x: float) -> int:
	return 0 if x < 512.0 else (1 if x < 1000.0 else 2)

func _is_skyscraper(r: Rect2) -> bool:
	return r.size.y >= float(level.get("skyscraper_min_height", 100))

# ── BACKDROP: sky, sun/moon, distant skyline (painted once) ──────────────
func _paint_backdrop(c: Node2D) -> void:
	var step := 40.0
	var x := -400.0
	while x < float(level.width) + 400.0:
		var w0 := zone_weight(x)
		var w1 := zone_weight(x + step)
		for i in range(SKY_Y.size() - 1):
			c.draw_polygon(
				PackedVector2Array([Vector2(x, SKY_Y[i]), Vector2(x + step, SKY_Y[i]), Vector2(x + step, SKY_Y[i + 1]), Vector2(x, SKY_Y[i + 1])]),
				PackedColorArray([_sky(w0, i), _sky(w1, i), _sky(w1, i + 1), _sky(w0, i + 1)]))
		x += step
	c.draw_rect(Rect2(-400, 345, float(level.width) + 800, 200), Color("07080c"))

	# Queens: rising sun with a soft halo.
	for k in range(4):
		c.draw_circle(Vector2(190, 262), 30.0 + k * 12.0, Color(1.0, 0.72, 0.35, 0.10), true, -1.0, true)
	c.draw_circle(Vector2(190, 262), 26, Color("ffd36b"), true, -1.0, true)
	# Midtown: soft layered clouds.
	for cl in [[560, 118, 1.0], [690, 96, 1.3], [830, 128, 0.9], [945, 104, 1.1]]:
		var cp := Vector2(cl[0], cl[1])
		var sc: float = cl[2]
		for blob in [[-16, 4, 10], [-4, -2, 13], [10, 0, 11], [22, 5, 8], [3, 6, 10]]:
			c.draw_circle(cp + Vector2(blob[0], blob[1]) * sc, blob[2] * sc, Color(1, 1, 1, 0.55), true, -1.0, true)
	# Manhattan: moon and stars.
	for i in range(90):
		var sx := float((i * 313 + 127) % 1500) + 1000
		var sy := float((i * 97 + 43) % 150) + 80
		var twinkle := 0.5 + 0.5 * float((i * 7) % 3) / 2.0
		c.draw_rect(Rect2(sx, sy, 1 + (i % 2), 1 + (i % 2)), Color(0.8, 0.86, 1.0, twinkle))
	# Full moon with soft glow and craters, clear of the Chrysler spire.
	var moon := Vector2(1745, 118)
	for k in range(3):
		c.draw_circle(moon, 20.0 + k * 8.0, Color(0.96, 0.9, 0.63, 0.07), true, -1.0, true)
	c.draw_circle(moon, 15, Color("f3e7b3"), true, -1.0, true)
	for cr in [[-5, -4, 3.0], [4, 2, 2.4], [-2, 6, 1.8], [6, -6, 1.4]]:
		c.draw_circle(moon + Vector2(cr[0], cr[1]), cr[2], Color("d9cb92"), true, -1.0, true)

	# Queens: brownstones with stoop-lit windows and chimneys.
	for b in [[0,235,48],[55,218,40],[105,232,44],[158,212,38],[204,228,52],[268,220,40],[318,235,38],[366,224,48],[424,214,58]]:
		var bx: float = b[0]; var by: float = b[1]; var bw: float = b[2]
		c.draw_rect(Rect2(bx, by, bw, 345 - by), Color("4a2616"))
		c.draw_rect(Rect2(bx - 2, by, bw + 4, 4), Color("5e3220"))
		c.draw_rect(Rect2(bx + bw * 0.5 - 3, by - 10, 6, 10), Color("3e1e10"))
		for wy in range(int(by) + 9, 330, 14):
			for wx in range(int(bx) + 5, int(bx + bw) - 6, 11):
				var lit := (wx * 7 + wy * 11) % 5 != 0
				c.draw_rect(Rect2(wx, wy, 5, 8), Color("ffc978") if lit else Color("2a150c"))
	# Midtown: glass towers with vertical mullions.
	for b in [[510,175,52],[572,148,45],[625,168,58],[693,140,50],[753,160,48],[811,130,65],[886,155,52],[948,138,50]]:
		var bx: float = b[0]; var by: float = b[1]; var bw: float = b[2]
		c.draw_rect(Rect2(bx, by, bw, 345 - by), Color("2a4f78"))
		c.draw_rect(Rect2(bx + bw * 0.62, by, bw * 0.38, 345 - by), Color("223f60"))
		for wy in range(int(by) + 5, 340, 9):
			c.draw_rect(Rect2(bx + 3, wy, bw - 6, 5), Color(0.55, 0.8, 0.95, 0.35))
		for wx in range(int(bx) + 3, int(bx + bw) - 3, 7):
			c.draw_line(Vector2(wx, by + 4), Vector2(wx, 345), Color(0.1, 0.2, 0.3, 0.5), 1)
		c.draw_line(Vector2(bx + bw * 0.5, by), Vector2(bx + bw * 0.5, by - 16), Color("35597f"), 2)
	# Manhattan: far silhouettes, lit mid-rise blocks, Empire State and Chrysler.
	for b in [[960,162,52],[1022,140,48],[1080,157,55],[1145,130,60],[1215,150,50],
			  [1275,167,45],[1330,142,55],[1395,154,48],[1453,132,60],[1523,157,50],
			  [1590,145,55],[1655,128,62],[1728,158,48],[1788,138,55],[1855,165,50],
			  [1918,142,58],[1985,155,45],[2048,130,62],[2122,150,50],[2182,168,45],
			  [2238,140,58],[2305,155,50],[2368,130,62],[2432,148,50],[2490,162,55]]:
		c.draw_rect(Rect2(b[0], b[1], b[2], 345 - b[1]), Color("0b1322"))
	var EMPIRE := Color("0e182a")
	c.draw_rect(Rect2(1048, 98, 24, 250), EMPIRE)
	c.draw_rect(Rect2(1038, 130, 44, 218), EMPIRE)
	c.draw_rect(Rect2(1029, 155, 62, 193), EMPIRE)
	c.draw_rect(Rect2(1020, 174, 80, 174), EMPIRE)
	c.draw_line(Vector2(1060, 98), Vector2(1060, 62), EMPIRE, 4)
	c.draw_circle(Vector2(1060, 62), 2, Color("ff4444"), true, -1.0, true)
	for wy in range(104, 340, 8):
		c.draw_rect(Rect2(1051, wy, 2, 4), Color(1, 0.85, 0.5, 0.45))
		c.draw_rect(Rect2(1067, wy, 2, 4), Color(1, 0.85, 0.5, 0.45))
	c.draw_rect(Rect2(1880, 110, 18, 238), EMPIRE)
	c.draw_rect(Rect2(1872, 138, 34, 210), EMPIRE)
	c.draw_rect(Rect2(1864, 158, 50, 190), EMPIRE)
	for k in range(4):
		var ry := 110.0 - k * 9.0
		c.draw_arc(Vector2(1889, ry + 9), 9.0 - k * 2.0, PI, TAU, 10, Color(0.95, 0.9, 0.7, 0.55), 1.0, true)
	c.draw_colored_polygon(PackedVector2Array([Vector2(1885, 84), Vector2(1889, 58), Vector2(1893, 84)]), EMPIRE)
	for b in [[975,240,36],[1022,227,32],[1065,242,40],[1115,230,34],[1160,246,38],
			  [1208,234,34],[1252,250,38],[1300,238,34],[1345,254,40],[1395,242,36],
			  [1442,258,38],[1490,246,34],[1545,240,38],[1592,228,34],[1638,244,40],
			  [1688,232,36],[1735,248,38],[1782,236,34],[1828,252,40],[1878,240,36],
			  [1925,256,38],[1972,244,34],[2018,260,40],[2068,248,36],[2115,242,38],
			  [2162,228,34],[2208,244,38],[2255,232,36],[2302,248,40],[2350,236,34],
			  [2396,252,38],[2442,240,36],[2488,256,40]]:
		var bx: float = b[0]; var by: float = b[1]; var bw: float = b[2]
		c.draw_rect(Rect2(bx, by, bw, 345 - by), Color("121c2e"))
		for wy in range(int(by) + 5, 340, 12):
			for wx in range(int(bx) + 4, int(bx + bw) - 4, 9):
				if (wx * 17 + wy * 11) % 7 > 2:
					c.draw_rect(Rect2(wx, wy, 4, 6), Color(0.95, 0.78, 0.36, 0.55))

# ── VILLAINS (animated every frame, behind the rooftops) ─────────────────
func _paint_villains(c: Node2D) -> void:
	var t := anim_time
	# Vulture swoops back and forth over Queens.
	var vphase := t * 0.45
	var vx := 300.0 + sin(vphase) * 150.0
	Villains.draw_vulture(c, Vector2(vx, 150.0 + sin(t * 1.7) * 14.0), signf(cos(vphase)) if cos(vphase) != 0 else 1.0, t, 1.5)
	# Green Goblin patrols the Midtown sky on his glider.
	var gphase := t * 0.35 + 1.0
	var gx := 760.0 + sin(gphase) * 170.0
	Villains.draw_goblin(c, Vector2(gx, 160.0 + sin(t * 2.0) * 16.0), signf(cos(gphase)) if cos(gphase) != 0 else 1.0, t, 1.45)
	# Doctor Octopus stalks the Manhattan roofline on his tentacles.
	Villains.draw_doc_ock(c, Vector2(1262.0 + sin(t * 0.4) * 10.0, 220.0), -1.0, t, 1.35)

# ── ROOFTOPS: every solid is a real building down to the street ──────────
func _paint_rooftops(c: Node2D) -> void:
	for entry in level.solids:
		var r := Rect2(entry[0], entry[1], entry[2], entry[3])
		if _is_skyscraper(r):
			_paint_skyscraper(c, r)
		else:
			_paint_building(c, r)
	_paint_finish(c)

func _paint_building(c: Node2D, r: Rect2) -> void:
	var zone := _zone_of(r.position.x)
	var body: Color = [Color("5a3320"), Color("33475c"), Color("3a3f4c")][zone]
	var cap: Color = [Color("a8744f"), Color("8fb4d4"), Color("aab0bc")][zone]
	var trim: Color = [Color("6a4030"), Color("46627d"), Color("5a606d")][zone]
	var lit: Color = [Color("ffcf86"), Color("9fd8f5"), Color("f5cc60")][zone]
	var bottom := 345.0
	# A small step (block on a roof) is just a raised parapet — no facade below.
	var is_step := r.size.x <= 48.0 and r.size.y <= 32.0
	if not is_step:
		# Dark outline separates playable buildings from the skyline behind.
		c.draw_rect(Rect2(r.position.x - 2, r.position.y, r.size.x + 4, bottom - r.position.y), Color("08090d"))
		c.draw_rect(Rect2(r.position.x, r.position.y, r.size.x, bottom - r.position.y), body)
		c.draw_rect(Rect2(r.end.x - 6, r.position.y, 6, bottom - r.position.y), body.darkened(0.25))
		for wy in range(int(r.position.y) + 14, int(bottom) - 4, 13):
			for wx in range(int(r.position.x) + 6, int(r.end.x) - 10, 12):
				var on := (wx * 13 + wy * 7) % 5 != 0
				c.draw_rect(Rect2(wx, wy, 6, 8), lit if on else body.darkened(0.4))
	else:
		c.draw_rect(r, trim)
	# Roof surface: the line you land on.
	c.draw_rect(Rect2(r.position.x - 1, r.position.y, r.size.x + 2, 6), trim)
	c.draw_rect(Rect2(r.position.x - 1, r.position.y, r.size.x + 2, 2), cap)
	if zone == 0 and r.size.x > 80:
		var cx := r.position.x + 15
		while cx < r.end.x - 15:
			c.draw_rect(Rect2(cx, r.position.y - 10, 8, 10), Color("6a3a22"))
			c.draw_rect(Rect2(cx - 1, r.position.y - 11, 10, 3), Color("8a5a40"))
			cx += 45
	elif zone == 2 and r.size.x >= 80:
		var ac := r.position.x + 10
		while ac < r.end.x - 22:
			c.draw_rect(Rect2(ac, r.position.y - 7, 14, 7), Color("4c515c"))
			c.draw_rect(Rect2(ac + 2, r.position.y - 6, 10, 1), Color("2a2d33"))
			c.draw_circle(Vector2(ac + 7, r.position.y - 3.5), 2.0, Color("2a2d33"), true, -1.0, true)
			ac += 42

## Skyscrapers are tall solids: only reachable with the web-zip double jump.
func _paint_skyscraper(c: Node2D, r: Rect2) -> void:
	var zone := _zone_of(r.position.x)
	var night := zone == 2
	var body := Color("1d3a5c") if not night else Color("1b2436")
	var glass := Color(0.55, 0.82, 0.97, 0.75) if not night else Color("f2c65c")
	var bottom := 345.0
	var x0 := r.position.x
	var x1 := r.end.x
	var top := r.position.y
	c.draw_rect(Rect2(x0 - 2, top, r.size.x + 4, bottom - top), Color("08090d"))
	c.draw_rect(Rect2(x0, top, r.size.x, bottom - top), body)
	# Shaded right face gives the tower some volume.
	c.draw_rect(Rect2(x1 - r.size.x * 0.3, top, r.size.x * 0.3, bottom - top), body.darkened(0.3))
	# Window grid: continuous glass bands by day, scattered lit offices at night.
	for wy in range(int(top) + 12, int(bottom) - 2, 8):
		for wx in range(int(x0) + 4, int(x1) - 4, 7):
			if night:
				if (wx * 31 + wy * 17) % 9 > 3:
					c.draw_rect(Rect2(wx, wy, 4, 5), glass)
			else:
				var shade := 0.75 + 0.25 * sin(float(wy) * 0.15 + float(wx) * 0.05)
				c.draw_rect(Rect2(wx, wy, 5, 6), Color(glass.r, glass.g, glass.b, glass.a * shade))
	# Vertical piers every few columns.
	var px := x0 + 2
	while px < x1:
		c.draw_rect(Rect2(px, top + 8, 2, bottom - top - 8), body.lightened(0.12))
		px += 21
	# Crown: setback cornice and landing parapet.
	c.draw_rect(Rect2(x0 - 3, top, r.size.x + 6, 8), body.lightened(0.25))
	c.draw_rect(Rect2(x0 - 3, top, r.size.x + 6, 2), Color("c8d4e0") if not night else Color("8a93a6"))
	c.draw_rect(Rect2(x0 - 1, top + 8, r.size.x + 2, 3), body.darkened(0.4))
	# Spire with a blinking aviation light at the back edge.
	var sx := x1 - 10
	c.draw_rect(Rect2(sx - 3, top - 12, 6, 12), body.lightened(0.18))
	c.draw_line(Vector2(sx, top - 12), Vector2(sx, top - 46), Color("9aa6b8"), 1.5, true)
	c.draw_circle(Vector2(sx, top - 46), 2.0, Color("ff3a3a"), true, -1.0, true)
	if night:
		# NYC water tower on the front corner.
		var wx := x0 + 8
		c.draw_line(Vector2(wx + 1, top), Vector2(wx + 3, top - 8), Color("3a2a1a"), 1.2)
		c.draw_line(Vector2(wx + 11, top), Vector2(wx + 9, top - 8), Color("3a2a1a"), 1.2)
		c.draw_rect(Rect2(wx, top - 20, 12, 12), Color("6b4a2e"))
		c.draw_colored_polygon(PackedVector2Array([Vector2(wx - 1, top - 20), Vector2(wx + 6, top - 26), Vector2(wx + 13, top - 20)]), Color("4a3220"))
		for k in range(3):
			c.draw_line(Vector2(wx, top - 17 + k * 4), Vector2(wx + 12, top - 17 + k * 4), Color("3a2a1a"), 0.8)
	else:
		# Rooftop helipad marking on the glass tower.
		c.draw_arc(Vector2(x0 + r.size.x * 0.4, top - 0.5), 7.0, PI, TAU, 12, Color("ffd23a"), 1.0, true)

func _paint_finish(c: Node2D) -> void:
	var finish_x: float = level.finish[0]
	var finish_top: float = level.finish[1]
	var pole_top: float = finish_top - 10
	var finish_bottom: float = finish_top + level.finish[3]
	c.draw_line(Vector2(finish_x + 3, finish_bottom), Vector2(finish_x + 3, pole_top), Color("c0c4cc"), 3)
	c.draw_colored_polygon(PackedVector2Array([Vector2(finish_x+5,pole_top),Vector2(finish_x+36,pole_top+12),Vector2(finish_x+5,pole_top+26)]), Color("CE1620"))
	var fx := finish_x + 17; var fy := pole_top + 13
	c.draw_circle(Vector2(fx, fy - 1.5), 1.6, Color("111111"), true, -1.0, true)
	c.draw_circle(Vector2(fx, fy + 1.5), 2.2, Color("111111"), true, -1.0, true)
	for side in [-1.0, 1.0]:
		for k in range(4):
			var knee := Vector2(fx + side * 4.0, fy - 2.5 + k * 1.6)
			c.draw_line(Vector2(fx, fy - 1 + k * 0.8), knee, Color("111111"), 0.8, true)
			c.draw_line(knee, knee + Vector2(side * 1.5, (k - 1.5) * 1.6), Color("111111"), 0.8, true)

# ── TAXIS (static and moving) ─────────────────────────────────────────────
func _paint_taxis(c: Node2D) -> void:
	for area in taxi_areas:
		var dir := 1.0
		var moving := false
		for m in movers:
			if m.area == area:
				dir = m.dir
				moving = true
		_draw_taxi(c, area.position, dir, moving)

func _draw_taxi(c: Node2D, p: Vector2, dir: float, moving: bool) -> void:
	var YELLOW := Color("ffcc1a")
	var YELLOW_D := Color("d99a00")
	var INK := Color("111118")
	# Local 24x16 box, mirrored so headlights lead the direction of travel.
	c.draw_set_transform(p + Vector2(12, 0), 0.0, Vector2(dir, 1.0))
	var o := Vector2(-12, 0)
	var shell := PackedVector2Array([o + Vector2(0.5, 13.5), o + Vector2(0.5, 8), o + Vector2(5, 6.5), o + Vector2(8, 1.8),
		o + Vector2(16.5, 1.8), o + Vector2(19.5, 6.5), o + Vector2(23.5, 7.5), o + Vector2(23.5, 13.5)])
	var big := PackedVector2Array()
	for q in shell:
		big.append(q + (q - (o + Vector2(12, 9))).normalized() * 0.8)
	c.draw_colored_polygon(big, INK)
	c.draw_colored_polygon(shell, YELLOW)
	c.draw_rect(Rect2(o + Vector2(0.5, 11), Vector2(23, 2.5)), YELLOW_D)
	# Windows with a civilian passenger in the back seat.
	c.draw_colored_polygon(PackedVector2Array([o + Vector2(12.8, 2.8), o + Vector2(16, 2.8), o + Vector2(18.5, 6.4), o + Vector2(12.8, 6.4)]), Color("2a4a6a"))
	c.draw_colored_polygon(PackedVector2Array([o + Vector2(8.6, 2.8), o + Vector2(11.8, 2.8), o + Vector2(11.8, 6.4), o + Vector2(6.2, 6.4)]), Color("2a4a6a"))
	c.draw_circle(o + Vector2(9.8, 5.2), 1.3, Color("e2b48c"), true, -1.0, true)
	c.draw_circle(o + Vector2(15.2, 5.2), 1.3, Color("5a3a26"), true, -1.0, true)
	# Checker stripe, roof sign, lights.
	for k in range(11):
		c.draw_rect(Rect2(o + Vector2(1.5 + k * 2.0, 8.2 + (k % 2) * 1.0), Vector2(1.0, 1.0)), INK)
	c.draw_rect(Rect2(o + Vector2(10, -0.6), Vector2(5, 2.4)), Color("fff4c0"))
	c.draw_rect(Rect2(o + Vector2(10, -0.6), Vector2(5, 0.6)), INK)
	c.draw_rect(Rect2(o + Vector2(22.4, 8.2), Vector2(1.4, 1.8)), Color("fffbe0"))
	c.draw_rect(Rect2(o + Vector2(0.2, 8.2), Vector2(1.2, 1.8)), Color("ff3030"))
	if moving:
		c.draw_colored_polygon(PackedVector2Array([o + Vector2(24, 8.2), o + Vector2(38, 5.5), o + Vector2(38, 13)]), Color(1.0, 0.97, 0.75, 0.18))
	# Wheels (spokes spin while driving).
	for wx in [5.5, 18.5]:
		var wc := o + Vector2(wx, 13.8)
		c.draw_circle(wc, 2.7, INK, true, -1.0, true)
		c.draw_circle(wc, 1.2, Color("9aa0aa"), true, -1.0, true)
		if moving:
			var a := elapsed * 12.0
			c.draw_line(wc - Vector2(cos(a), sin(a)) * 1.2, wc + Vector2(cos(a), sin(a)) * 1.2, INK, 0.5)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
