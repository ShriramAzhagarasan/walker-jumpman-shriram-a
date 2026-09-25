extends RefCounted
## Procedural background villains. Each draw_* call paints onto `c` in world
## space around `pos`, mirrored by `dir` (1 = facing right), animated by `t`.
## Purely decorative: none of these have collision.

const INK := Color("0d0d14")

static func _ellipse(centre: Vector2, rx: float, ry: float, segments: int = 18) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in range(segments):
		var a := TAU * float(i) / segments
		pts.append(centre + Vector2(cos(a) * rx, sin(a) * ry))
	return pts

static func _capsule(c: CanvasItem, a: Vector2, b: Vector2, w: float, col: Color, outline: bool) -> void:
	var ww := w + (1.6 if outline else 0.0)
	var cc := INK if outline else col
	c.draw_line(a, b, cc, ww)
	c.draw_circle(a, ww * 0.5, cc)
	c.draw_circle(b, ww * 0.5, cc)

static func _poly(c: CanvasItem, pts: PackedVector2Array, col: Color, outline: bool) -> void:
	if outline:
		var centre := Vector2.ZERO
		for p in pts:
			centre += p
		centre /= pts.size()
		var big := PackedVector2Array()
		for p in pts:
			big.append(p + (p - centre).normalized() * 0.9)
		c.draw_colored_polygon(big, INK)
	else:
		c.draw_colored_polygon(pts, col)

static func _bezier(a: Vector2, ctrl: Vector2, b: Vector2, u: float) -> Vector2:
	return a.lerp(ctrl, u).lerp(ctrl.lerp(b, u), u)

# ── VULTURE (Adrian Toomes, classic): green feathered wings, white ruff ───
static func _vulture_wing(c: CanvasItem, root: Vector2, flap: float, main: Color, tip: Color, edge: Color, outline: bool) -> void:
	# Leading edge root -> wrist -> tip, then a scalloped trailing edge of primaries.
	var rot := Transform2D(flap, Vector2.ZERO)
	var wrist := root + rot * Vector2(-8, -18)
	var wing_tip := root + rot * Vector2(-36, -24)
	var pts := PackedVector2Array([root, wrist, wing_tip])
	for i in range(1, 7):
		var u := float(i) / 7.0
		var edge_pt: Vector2 = wing_tip.lerp(root + Vector2(-16, 3), u)
		var notch := rot * Vector2(-3.5, 4.0) if i % 2 == 1 else Vector2.ZERO
		pts.append(edge_pt + notch)
	pts.append(root + Vector2(-6, 3))
	_poly(c, pts, main, outline)
	if outline:
		return
	# Long primary feathers along the trailing edge.
	for i in range(5):
		var u := 0.08 + float(i) * 0.17
		var base: Vector2 = wing_tip.lerp(root + Vector2(-16, 3), u)
		var along := (wing_tip - wrist).normalized()
		var out := rot * Vector2(-2.5, 7.5 - i * 0.8)
		var f := PackedVector2Array([base - along * 2.2, base + out, base + along * 2.2])
		c.draw_colored_polygon(f, tip)
	c.draw_line(root, wrist, edge, 1.6, true)
	c.draw_line(wrist, wing_tip, edge, 1.1, true)

static func draw_vulture(c: CanvasItem, pos: Vector2, dir: float, t: float, scale: float = 1.0) -> void:
	var GREEN := Color("3f8a2f")
	var GREEN_D := Color("25561c")
	var GREEN_L := Color("86c35a")
	var RUFF := Color("efe7cf")
	var SKIN := Color("e0bb98")
	var flap := sin(t * 5.0) * 0.45
	c.draw_set_transform(pos, 0.0, Vector2(dir, 1.0) * scale)
	for pass_i in range(2):
		var o := pass_i == 0
		_vulture_wing(c, Vector2(-2, -4), flap * 0.8 - 0.15, GREEN_D, Color("173d12"), GREEN, o)
		# Legs trailing behind with talons.
		_capsule(c, Vector2(-10, 2), Vector2(-21, 5), 3.6, GREEN_D, o)
		_capsule(c, Vector2(-9, 3), Vector2(-20, 8), 3.6, GREEN, o)
		# Body, horizontal in flight.
		_poly(c, _ellipse(Vector2(-1, 0), 12.0, 5.0), GREEN, o)
		# Reaching arm with claws.
		_capsule(c, Vector2(6, 1), Vector2(14, 5), 3.0, GREEN, o)
		if not o:
			c.draw_colored_polygon(_ellipse(Vector2(-2, 1.5), 9.0, 2.4), GREEN_L)
			for k in range(3):
				c.draw_line(Vector2(14, 5), Vector2(16.5, 4.0 + k * 1.6), SKIN, 0.8, true)
				c.draw_line(Vector2(-21, 5 + k * 0.1), Vector2(-24, 4.0 + k * 1.3), Color("c9a24a"), 0.8, true)
		# White feather ruff around the neck.
		var ruff := PackedVector2Array()
		for i in range(10):
			var a := -PI * 0.55 + PI * 1.1 * float(i) / 9.0
			var r := 5.4 if i % 2 == 0 else 3.6
			ruff.append(Vector2(9, -2) + Vector2(cos(a) * r - 1.5, sin(a) * r))
		ruff.append(Vector2(8, -2))
		_poly(c, ruff, RUFF, o)
		# Bald head, hooked nose, scowl.
		if o:
			c.draw_circle(Vector2(13, -6), 5.1, INK)
		else:
			c.draw_circle(Vector2(13, -6), 4.3, SKIN)
			c.draw_circle(Vector2(12, -7.5), 1.6, Color(1, 1, 1, 0.25))
			c.draw_colored_polygon(PackedVector2Array([Vector2(16, -7.5), Vector2(20.5, -5.2), Vector2(18.2, -3.4), Vector2(16.4, -4.2)]), Color("c79a78"))
			c.draw_line(Vector2(14, -8.2), Vector2(16.6, -7.4), INK, 0.9, true)
			c.draw_circle(Vector2(15.4, -6.8), 0.7, INK)
			c.draw_line(Vector2(14.6, -3.6), Vector2(16.4, -3.0), Color("6b3b2a"), 0.7, true)
			c.draw_circle(Vector2(10.6, -5.6), 1.0, Color("c79a78"))
		_vulture_wing(c, Vector2(1, -4), flap, GREEN, GREEN_D, GREEN_L, o)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

# ── GREEN GOBLIN (classic): purple hat and tunic, grin, bat glider, bomb ──
static func draw_goblin(c: CanvasItem, pos: Vector2, dir: float, t: float, scale: float = 1.0) -> void:
	var SKIN := Color("6fc23b")
	var SKIN_D := Color("3f8a22")
	var PURPLE := Color("6b2d91")
	var PURPLE_D := Color("45196a")
	var GLIDER := Color("3a4430")
	var GLIDER_L := Color("6d7d52")
	var tilt := sin(t * 2.0) * 0.06
	c.draw_set_transform(pos, tilt * dir, Vector2(dir, 1.0) * scale)
	# Jet flame behind the glider.
	var flick := 0.7 + 0.3 * sin(t * 31.0)
	c.draw_colored_polygon(PackedVector2Array([Vector2(-20, 1), Vector2(-20 - 12 * flick, 3), Vector2(-20, 5)]), Color(1.0, 0.55, 0.1, 0.85))
	c.draw_colored_polygon(PackedVector2Array([Vector2(-20, 2), Vector2(-20 - 6 * flick, 3), Vector2(-20, 4)]), Color(1.0, 0.95, 0.5, 0.95))
	for pass_i in range(2):
		var o := pass_i == 0
		# Back leg, then glider (bat wings with scalloped edges).
		_capsule(c, Vector2(-2, -13), Vector2(-5, -6), 3.6, SKIN_D, o)
		_capsule(c, Vector2(-5, -6), Vector2(-6, -1), 3.4, PURPLE_D, o)
		var wing := PackedVector2Array([
			Vector2(22, 1), Vector2(12, -2), Vector2(-12, -2), Vector2(-24, -8), Vector2(-20, 0),
			Vector2(-26, 3), Vector2(-18, 4), Vector2(-20, 8), Vector2(-10, 5), Vector2(0, 7),
			Vector2(10, 5), Vector2(18, 4)])
		_poly(c, wing, GLIDER, o)
		if not o:
			c.draw_line(Vector2(-12, -1.5), Vector2(20, 0.5), GLIDER_L, 1.2, true)
			c.draw_colored_polygon(PackedVector2Array([Vector2(14, 0), Vector2(18, 1), Vector2(14, 2.2)]), Color("ffd83a"))
			c.draw_colored_polygon(PackedVector2Array([Vector2(8, 0.3), Vector2(12, 1.2), Vector2(8, 2.4)]), Color("ffd83a"))
		# Front leg with purple boot planted on the glider.
		_capsule(c, Vector2(1, -13), Vector2(5, -7), 3.8, SKIN, o)
		_capsule(c, Vector2(5, -7), Vector2(4, -1.5), 3.6, PURPLE, o)
		_capsule(c, Vector2(4, -1.5), Vector2(7.5, -1.5), 2.6, PURPLE, o)
		# Tunic, leaning into the flight.
		var tunic := PackedVector2Array([
			Vector2(-4, -14), Vector2(4, -14), Vector2(6.5, -24), Vector2(0, -26.5), Vector2(-4.5, -23)])
		_poly(c, tunic, PURPLE, o)
		if not o:
			c.draw_line(Vector2(-3.5, -24), Vector2(4, -15), Color("7a4a1f"), 1.3, true)
			c.draw_rect(Rect2(-4.5, -16.5, 4, 3.5), Color("8a5a28"))
			c.draw_line(Vector2(-4, -14.5), Vector2(4, -14.5), PURPLE_D, 1.2, true)
		# Back arm: winding up to throw the pumpkin bomb.
		var wind := sin(t * 2.4) * 0.5
		var elbow := Vector2(-4, -26) + Vector2(-5, -1 - wind * 3)
		var fist := elbow + Vector2(-2, -6 + wind * 2)
		_capsule(c, Vector2(-1, -24), elbow, 3.0, SKIN, o)
		_capsule(c, elbow, fist, 3.0, PURPLE, o)
		# Head: green face, huge grin, pointed ear, floppy purple hat.
		if o:
			c.draw_circle(Vector2(6, -30), 5.9, INK)
		else:
			c.draw_circle(Vector2(6, -30), 5.1, SKIN)
			c.draw_colored_polygon(PackedVector2Array([Vector2(1.5, -31), Vector2(-2.5, -34.5), Vector2(2.5, -28.5)]), SKIN_D)
			var grin := PackedVector2Array([Vector2(5, -28.4), Vector2(11, -29.2), Vector2(10.2, -26.6), Vector2(7.2, -25.4), Vector2(5.4, -26.6)])
			c.draw_colored_polygon(grin, Color("2a0a10"))
			for k in range(4):
				var tx := 6.0 + k * 1.3
				c.draw_rect(Rect2(tx, -28.6 + k * -0.18, 1.0, 1.1), Color("fff6d6"))
			c.draw_colored_polygon(PackedVector2Array([Vector2(7, -32.6), Vector2(10.4, -31.2), Vector2(7.2, -30.8)]), Color("ffe03a"))
			c.draw_circle(Vector2(8.8, -31.5), 0.6, Color("c01010"))
			c.draw_line(Vector2(6.4, -33.6), Vector2(10.8, -32.2), SKIN_D, 1.0, true)
			c.draw_colored_polygon(PackedVector2Array([Vector2(10.5, -30.5), Vector2(13.4, -28.6), Vector2(10.6, -28.4)]), SKIN_D)
		_poly(c, PackedVector2Array([Vector2(0.6, -30.5), Vector2(1.4, -35.2), Vector2(6, -37), Vector2(10.6, -34.4), Vector2(3, -33)]), PURPLE, o)
		_poly(c, PackedVector2Array([Vector2(1.4, -35), Vector2(-3, -36), Vector2(-9.5, -30.5), Vector2(-4.5, -33.2), Vector2(1.5, -32.5)]), PURPLE_D if not o else PURPLE, o)
		if o:
			continue
		# Pumpkin bomb: jack-o'-lantern with a sparking fuse.
		var bomb := fist + Vector2(-1.5, -3.5)
		c.draw_circle(bomb, 4.0, INK)
		c.draw_circle(bomb, 3.3, Color("ff8a1a"))
		c.draw_arc(bomb, 1.8, -PI * 0.5, PI * 0.5, 8, Color("d8661a"), 0.6, true)
		c.draw_colored_polygon(PackedVector2Array([bomb + Vector2(-1.8, -0.8), bomb + Vector2(-0.6, -0.8), bomb + Vector2(-1.2, -2)]), Color("ffe36a"))
		c.draw_colored_polygon(PackedVector2Array([bomb + Vector2(0.6, -0.8), bomb + Vector2(1.8, -0.8), bomb + Vector2(1.2, -2)]), Color("ffe36a"))
		c.draw_line(bomb + Vector2(-1.6, 1.2), bomb + Vector2(1.6, 1.2), Color("ffe36a"), 0.8, true)
		c.draw_line(bomb + Vector2(0, -3.2), bomb + Vector2(0.8, -4.8), Color("3a6a1a"), 0.9, true)
		if fmod(t, 0.3) < 0.18:
			c.draw_circle(bomb + Vector2(1.0, -5.2), 1.0, Color("fff3a0"))
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

# ── DOCTOR OCTOPUS: trench coat, round goggles, four metal tentacles ──────
static func _tentacle(c: CanvasItem, base: Vector2, tip: Vector2, sway: Vector2, t: float, phase: float) -> void:
	var ctrl := base.lerp(tip, 0.5) + sway * (0.6 + 0.4 * sin(t * 1.8 + phase))
	var n := 16
	for pass_i in range(2):
		for i in range(n + 1):
			var u := float(i) / n
			var p := _bezier(base, ctrl, tip, u)
			var r := lerpf(2.8, 1.8, u)
			if pass_i == 0:
				c.draw_circle(p, r + 0.8, INK)
			else:
				c.draw_circle(p, r, Color("aab4c2") if i % 2 == 0 else Color("707b8c"))
				c.draw_circle(p + Vector2(-0.5, -0.6), r * 0.4, Color(1, 1, 1, 0.35))
	# Three-pronged claw with the red sensor light.
	var d := (tip - _bezier(base, ctrl, tip, 0.9)).normalized()
	var side := Vector2(-d.y, d.x)
	var open := 0.6 + 0.4 * sin(t * 3.0 + phase)
	for k in [-1.0, 0.0, 1.0]:
		var claw_tip: Vector2 = tip + d * 4.5 + side * k * 2.6 * open
		c.draw_line(tip, claw_tip, INK, 2.2, true)
		c.draw_line(tip, claw_tip, Color("c9d1dc"), 1.1, true)
	c.draw_circle(tip, 2.4, INK)
	c.draw_circle(tip, 1.7, Color("59616e"))
	c.draw_circle(tip, 0.9, Color("ff3030"))

static func draw_doc_ock(c: CanvasItem, pos: Vector2, dir: float, t: float, scale: float = 1.0) -> void:
	var COAT := Color("4a5236")
	var COAT_D := Color("30361f")
	var SKIN := Color("e6c3a2")
	var bob := sin(t * 1.8) * 1.5
	c.draw_set_transform(pos + Vector2(0, bob * scale), 0.0, Vector2(dir, 1.0) * scale)
	var harness := Vector2(-2, -14)
	# Two tentacles plant on the ledge below and hold him up; two strike overhead.
	_tentacle(c, harness, Vector2(-26, 22 - bob), Vector2(-6, 4), t, 0.0)
	_tentacle(c, harness, Vector2(22, 22 - bob), Vector2(6, 5), t, 1.3)
	# Upper pair rears from behind his shoulders and arcs outward, poised to strike.
	_tentacle(c, harness + Vector2(-2, -4), Vector2(-30 + sin(t * 1.3) * 4, -40 + cos(t * 1.7) * 4), Vector2(-14, 10), t, 2.1)
	_tentacle(c, harness + Vector2(2, -4), Vector2(32 + cos(t * 1.1) * 4, -36 + sin(t * 1.9) * 4), Vector2(14, 10), t, 3.4)
	for pass_i in range(2):
		var o := pass_i == 0
		# Dangling legs.
		_capsule(c, Vector2(-2, -6), Vector2(-3, 4), 3.8, Color("2a2a30"), o)
		_capsule(c, Vector2(2, -6), Vector2(3, 4), 3.8, Color("35353c"), o)
		_capsule(c, Vector2(-3, 4), Vector2(-1, 5), 2.6, INK, o)
		_capsule(c, Vector2(3, 4), Vector2(5, 5), 2.6, INK, o)
		# Heavy trench coat.
		var coat := PackedVector2Array([
			Vector2(-6.5, -21), Vector2(6.5, -21), Vector2(8, -9), Vector2(7, 0), Vector2(-7, 0), Vector2(-8, -9)])
		_poly(c, coat, COAT, o)
		if not o:
			c.draw_colored_polygon(PackedVector2Array([Vector2(-1, -21), Vector2(1.5, -21), Vector2(0.8, -12), Vector2(-0.4, -12)]), Color("ddd8c8"))
			c.draw_colored_polygon(PackedVector2Array([Vector2(-4, -21), Vector2(-1, -21), Vector2(-0.4, -12), Vector2(-3, -15)]), COAT_D)
			c.draw_colored_polygon(PackedVector2Array([Vector2(1.5, -21), Vector2(4.5, -21), Vector2(3, -15), Vector2(0.8, -12)]), COAT_D)
			c.draw_line(Vector2(-7.6, -10), Vector2(7.6, -10), COAT_D, 1.4, true)
			c.draw_rect(Rect2(-5, -16, 8, 3), Color("7d8796"))
		# Arms folded across the coat.
		_capsule(c, Vector2(-6, -19), Vector2(-5, -12), 3.4, COAT_D, o)
		_capsule(c, Vector2(6, -19), Vector2(5, -12), 3.4, COAT_D, o)
		_capsule(c, Vector2(-5, -12), Vector2(3, -13), 3.0, COAT, o)
		# Head: bowl haircut, round dark goggles, stern frown.
		if o:
			c.draw_circle(Vector2(0.5, -26.5), 5.9, INK)
			continue
		c.draw_circle(Vector2(0.5, -26.5), 5.1, SKIN)
		c.draw_colored_polygon(PackedVector2Array([
			Vector2(-5, -26), Vector2(-4.6, -30), Vector2(-1, -32.2), Vector2(3.5, -31.8),
			Vector2(5.8, -29), Vector2(5.4, -27.8), Vector2(0, -29.4), Vector2(-3.4, -28.4), Vector2(-4, -24.6)]), Color("15151a"))
		for gx in [-1.6, 2.8]:
			c.draw_circle(Vector2(gx, -26.4), 2.0, INK)
			c.draw_circle(Vector2(gx, -26.4), 1.5, Color("1e2530"))
			c.draw_circle(Vector2(gx - 0.5, -27.0), 0.5, Color(1, 1, 1, 0.8))
		c.draw_line(Vector2(0.4, -26.4), Vector2(0.8, -26.4), INK, 0.8, true)
		c.draw_line(Vector2(-1.2, -22.9), Vector2(2.4, -23.1), Color("7a3a2a"), 0.8, true)
		c.draw_line(Vector2(-3.4, -29.0), Vector2(-0.2, -28.6), INK, 0.8, true)
		c.draw_line(Vector2(1.4, -28.6), Vector2(4.4, -29.0), INK, 0.8, true)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
