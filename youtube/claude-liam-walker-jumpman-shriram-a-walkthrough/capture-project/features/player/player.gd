extends CharacterBody2D

const Tuning = preload("res://features/player/tuning.gd")
## World y of the play-area ceiling (just under the HUD top bar). Webs stick here.
const WEB_CEILING_Y := 78.0

const RED    := Color("d3202b")
const RED_D  := Color("8f0f18")
const BLUE   := Color("2356b8")
const BLUE_D := Color("16357a")
const WHITE  := Color("f4f7ff")
const INK    := Color("0b0b14")
const WEB    := Color(0.92, 0.95, 1.0, 0.95)

var tuning = Tuning.new()
var enabled: bool = false
var tick: int = 0
var last_floor_tick: int = -1000
var jump_request_tick: int = -1000
var opportunity_consumed: bool = false
var require_jump_release: bool = true
var facing: float = 1.0
var jumps: int = 0            ## ground jumps (including coyote/buffered)
var air_jumps_used: int = 0   ## web-zip jumps spent in the current airtime
var air_jumps_total: int = 0  ## web-zip jumps this attempt
var web_active: bool = false
var web_anchor: Vector2 = Vector2.ZERO
var web_age: int = 0
var anim_phase: float = 0.0
var test_control: bool = false
var test_axis: float = 0.0
var test_jump_pressed: bool = false
var test_jump_held: bool = false

func _ready() -> void:
	name = "Player"
	collision_layer = 2
	collision_mask = 1
	floor_snap_length = 1.0
	var shape := RectangleShape2D.new()
	shape.size = Vector2(18, 28)
	var collider := CollisionShape2D.new()
	collider.shape = shape
	collider.position = Vector2(0, -14)
	add_child(collider)

func reset_at(spawn: Vector2) -> void:
	position = spawn
	velocity = Vector2.ZERO
	last_floor_tick = -1000
	jump_request_tick = -1000
	opportunity_consumed = false
	require_jump_release = true
	test_jump_pressed = false
	jumps = 0
	air_jumps_used = 0
	air_jumps_total = 0
	web_active = false
	queue_redraw()

func _physics_process(delta: float) -> void:
	if not enabled:
		return
	tick += 1
	var axis := test_axis if test_control else Input.get_axis("move_left", "move_right")
	var held := test_jump_held if test_control else Input.is_action_pressed("jump")
	var pressed := test_jump_pressed if test_control else Input.is_action_just_pressed("jump")
	test_jump_pressed = false
	if not held:
		require_jump_release = false
	if is_on_floor() and velocity.y >= 0.0:
		last_floor_tick = tick
		opportunity_consumed = false
		air_jumps_used = 0
		web_active = false
	var fresh_press := pressed and not require_jump_release
	if fresh_press:
		jump_request_tick = tick
	var rate: float = tuning.acceleration if not is_zero_approx(axis) else tuning.deceleration
	velocity.x = move_toward(velocity.x, axis * tuning.speed, rate * delta)
	if not is_zero_approx(axis):
		facing = signf(axis)
	velocity.y = minf(velocity.y + tuning.gravity * delta, tuning.terminal_velocity)
	var can_ground_jump: bool = not opportunity_consumed and tick - last_floor_tick <= tuning.coyote_ticks
	if can_ground_jump and tick - jump_request_tick <= tuning.buffer_ticks:
		velocity.y = tuning.jump_velocity
		opportunity_consumed = true
		jump_request_tick = -1000
		jumps += 1
		_shoot_web(72.0)
	elif fresh_press and not can_ground_jump and air_jumps_used < tuning.air_jumps:
		# Web-zip: a second, fresh press in the air. Never buffered into a landing.
		velocity.y = tuning.air_jump_velocity
		jump_request_tick = -1000
		air_jumps_used += 1
		air_jumps_total += 1
		_shoot_web(56.0)
	move_and_slide()
	position.x = maxf(position.x, 10.0)
	anim_phase += delta * absf(velocity.x) * 0.085
	web_age += 1
	# Let go once the swing has carried us well past the anchor.
	if web_active and (web_anchor.x - position.x) * facing < -150.0:
		web_active = false
	queue_redraw()

func _shoot_web(lead: float) -> void:
	web_anchor = Vector2(position.x + facing * lead + velocity.x * 0.15, WEB_CEILING_Y)
	web_active = true
	web_age = 0

# ── Drawing helpers (local space faces right; _draw mirrors by `facing`) ────
func _dir(angle: float) -> Vector2:
	# angle 0 = straight down, positive = toward facing direction, PI = up.
	return Vector2(sin(angle), cos(angle))

func _capsule(a: Vector2, b: Vector2, width: float, color: Color, outline: bool) -> void:
	var w := width + (1.3 if outline else 0.0)
	var c := INK if outline else color
	draw_line(a, b, c, w)
	draw_circle(a, w * 0.5, c)
	draw_circle(b, w * 0.5, c)

func _expand(points: PackedVector2Array, amount: float) -> PackedVector2Array:
	var centre := Vector2.ZERO
	for p in points:
		centre += p
	centre /= points.size()
	var out := PackedVector2Array()
	for p in points:
		out.append(p + (p - centre).normalized() * amount)
	return out

func _leg(hip: Vector2, thigh: float, bend: float, dark: bool, outline: bool) -> void:
	var knee := hip + _dir(thigh) * 5.2
	var shin := thigh - bend
	var ankle := knee + _dir(shin) * 4.5
	var toe := ankle + _dir(shin + PI * 0.5) * 2.2
	_capsule(hip, knee, 3.8, BLUE_D if dark else BLUE, outline)
	_capsule(knee, ankle, 3.4, RED_D if dark else RED, outline)
	_capsule(ankle, toe, 2.4, RED_D if dark else RED, outline)
	if not outline:
		# Boot cuff just below the knee.
		var cuff := knee.lerp(ankle, 0.25)
		var side := _dir(shin + PI * 0.5) * 1.7
		draw_line(cuff - side, cuff + side, INK if dark else RED_D, 0.6, true)

func _hand_of(shoulder: Vector2, upper: float, bend: float) -> Vector2:
	return shoulder + _dir(upper) * 4.3 + _dir(upper + bend) * 4.0

func _arm(shoulder: Vector2, upper: float, bend: float, dark: bool, outline: bool) -> void:
	var elbow := shoulder + _dir(upper) * 4.3
	var hand := _hand_of(shoulder, upper, bend)
	_capsule(shoulder, elbow, 2.9, BLUE_D if dark else BLUE, outline)
	_capsule(elbow, hand, 2.7, RED_D if dark else RED, outline)
	draw_circle(hand, 1.95 if outline else 1.3, INK if outline else (RED_D if dark else RED))

func _draw() -> void:
	var airborne := not is_on_floor()
	var running := not airborne and absf(velocity.x) > 8.0
	var s := sin(anim_phase)
	var lean := 0.0
	var bob := 0.0
	var legs := [[-0.1, 0.06], [0.12, 0.1]]          # [thigh angle, knee bend] far, near
	var arms := [[-0.12, 0.3], [0.16, 0.4]]          # [upper angle, elbow bend] far, near
	if airborne:
		lean = 0.14
		if velocity.y < 0.0:
			legs = [[0.3, 1.5], [1.2, 1.9]]            # knees tucked on the rise
		else:
			legs = [[-0.4, 0.8], [0.6, 0.7]]           # legs spread for the landing
		arms = [[PI - 0.3, 0.0], [1.3, 0.6]]
	elif running:
		lean = 0.12
		bob = -absf(cos(anim_phase)) * 0.8
		legs = [[-0.75 * s, 0.25 + 1.1 * maxf(0.0, s)], [0.75 * s, 0.25 + 1.1 * maxf(0.0, -s)]]
		arms = [[0.8 * s, 1.3], [-0.8 * s, 1.3]]

	var hip := Vector2(0, -11 + bob)
	var shoulder := Vector2(9.0 * lean, -20.0 + bob)
	var head := Vector2(0.8 + 10.0 * lean, -24.6 + bob)
	var far_shoulder := shoulder + Vector2(-1.4, 0.3)
	var near_shoulder := shoulder + Vector2(1.2, 0.3)

	# The far arm aims the web at its ceiling anchor while attached.
	var anchor_local := web_anchor - position
	var anchor_flip := Vector2(anchor_local.x * facing, anchor_local.y)
	var show_web := airborne and web_active
	if show_web:
		var d := (anchor_flip - far_shoulder).normalized()
		arms[0] = [atan2(d.x, d.y), 0.0]

	# ── WEB LINE: from the wrist all the way to the ceiling (behind the body) ──
	if show_web:
		var h := _hand_of(far_shoulder, arms[0][0], arms[0][1])
		var start := Vector2(h.x * facing, h.y)
		var reach := clampf(float(web_age + 1) / 5.0, 0.0, 1.0)
		var end := start.lerp(anchor_local, reach)
		draw_line(start, end, Color(0.2, 0.25, 0.35, 0.5), 2.0, true)
		draw_line(start, end, WEB, 1.0, true)
		if reach >= 1.0:
			for k in range(7):
				var a := PI * float(k) / 6.0
				draw_line(end, end + Vector2(cos(a) * 6.0, sin(a) * 4.0), Color(WEB, 0.85), 0.6, true)
			draw_arc(end, 3.0, 0, PI, 10, Color(WEB, 0.7), 0.5, true)
			draw_arc(end, 5.0, 0.2, PI - 0.2, 12, Color(WEB, 0.45), 0.5, true)

	draw_set_transform(Vector2.ZERO, 0.0, Vector2(facing, 1.0))
	for pass_i in range(2):
		var outline := pass_i == 0
		# Far limbs first, in shadow tones.
		_leg(hip + Vector2(-1.1, 0), legs[0][0], legs[0][1], true, outline)
		_arm(far_shoulder, arms[0][0], arms[0][1], true, outline)
		var torso := PackedVector2Array([
			shoulder + Vector2(-3.6, -0.6), shoulder + Vector2(3.7, -0.6), shoulder + Vector2(4.1, 3.2),
			hip + Vector2(2.7, 0.3), hip + Vector2(-2.7, 0.3), shoulder + Vector2(-3.7, 3.4)])
		if outline:
			draw_colored_polygon(_expand(torso, 0.7), INK)
			draw_circle(head, 5.05, INK)
		else:
			# Torso: blue flanks, red chest and centre panel, red belt.
			draw_colored_polygon(torso, BLUE)
			draw_colored_polygon(PackedVector2Array([
				shoulder + Vector2(-3.4, -0.6), shoulder + Vector2(3.6, -0.6), shoulder + Vector2(3.9, 3.3),
				hip + Vector2(1.5, -0.8), hip + Vector2(-0.8, -0.8), shoulder + Vector2(-3.2, 3.3)]), RED)
			draw_rect(Rect2(hip + Vector2(-2.7, -1.2), Vector2(5.4, 1.1)), RED)
			var em := shoulder.lerp(hip, 0.36) + Vector2(0.4, 0)
			for k in range(6):
				var a := TAU * float(k) / 6.0 + 0.5
				draw_line(em, em + Vector2(cos(a) * 3.8, sin(a) * 3.6), Color(RED_D, 0.7), 0.3, true)
			# Spider emblem.
			draw_circle(em + Vector2(0, -0.6), 0.7, INK)
			draw_circle(em + Vector2(0, 0.5), 0.95, INK)
			for side in [-1.0, 1.0]:
				for k in range(4):
					var y0 := -0.8 + k * 0.55
					var knee_pt := em + Vector2(side * 1.5, y0 - 0.5 + k * 0.25)
					draw_line(em + Vector2(0, y0), knee_pt, INK, 0.35, true)
					draw_line(knee_pt, knee_pt + Vector2(side * 0.5, (k - 1.5) * 0.7), INK, 0.35, true)
			# Head: red mask, shaded back edge, webbing.
			draw_circle(head, 4.4, RED_D)
			draw_circle(head + Vector2(0.3, -0.25), 4.1, RED)
			for k in range(8):
				var a := TAU * float(k) / 8.0
				draw_line(head + Vector2(cos(a), sin(a)) * 0.7, head + Vector2(cos(a), sin(a)) * 4.2, Color(RED_D, 0.8), 0.3, true)
			draw_arc(head, 2.1, 0, TAU, 20, Color(RED_D, 0.8), 0.3, true)
			draw_arc(head, 3.4, 0, TAU, 24, Color(RED_D, 0.8), 0.3, true)
			draw_circle(head + Vector2(-1.7, -2.3), 0.9, Color(1, 1, 1, 0.2))
			# Eyes: big angled lenses with thick black frames (far eye foreshortened).
			var front_eye := PackedVector2Array([
				head + Vector2(1.1, 0.6), head + Vector2(1.2, -1.9), head + Vector2(3.7, -2.6),
				head + Vector2(4.2, -0.7), head + Vector2(3.0, 1.2)])
			var back_eye := PackedVector2Array([
				head + Vector2(0.2, 0.6), head + Vector2(0.1, -2.0), head + Vector2(-1.6, -2.3),
				head + Vector2(-2.3, -0.7), head + Vector2(-1.3, 1.0)])
			for eye in [back_eye, front_eye]:
				draw_colored_polygon(_expand(eye, 0.7), INK)
				draw_colored_polygon(eye, WHITE)
		_leg(hip + Vector2(1.0, 0), legs[1][0], legs[1][1], false, outline)
		_arm(near_shoulder, arms[1][0], arms[1][1], false, outline)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
