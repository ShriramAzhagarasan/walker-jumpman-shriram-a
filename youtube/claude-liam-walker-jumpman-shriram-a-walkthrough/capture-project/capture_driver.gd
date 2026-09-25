extends SceneTree
## Walkthrough capture driver (isolated harness copy, not part of the game source).
## Instantiates the REAL main scene and plays it only through Input.action_press /
## Input.action_release. It observes position/state to choose inputs, but never
## teleports, sets state, disables collision or touches test-only player hooks.
## Every input and observed game event is logged against the physics tick.
##
## Run under Godot Movie Maker:
##   Godot --path capture-project --script res://capture_driver.gd \
##     --resolution 3840x2160 --write-movie ../capture/run-01.avi --fixed-fps 30

const LOG_NAME := "run-01-inputs.jsonl"
const ROUTE_JUMPS := [138.0, 292.0, 424.0, 548.0, 625.0, 945.0, 1070.0, 1205.0, 1390.0, 1600.0, 1700.0, 1925.0, 2085.0, 2225.0]
const ROUTE_ZIPS := [683.0, 1258.0, 1790.0]
# Attempt 3 (coyote + buffer, then no web-zip at the first skyscraper).
const NOZIP_JUMPS := []  # attempt 3 uses _forgiveness_attempt() instead of fixed marks

var game: Node2D
var driver: Node
var log_file: FileAccess

class Driver extends Node:
	var tree_ref
	var game: Node2D
	var tick := 0
	var phase := "menu"
	var phase_tick := 0
	var jumps: Array = []
	var zips: Array = []
	var next_jump := 0
	var next_zip := 0
	var release_jump_at := -1
	var held := {}
	var last_state := -1
	var failed := ""
	var sub := 0
	var was_floor := true
	var mark_tick := 0
	var jumps_seen := 0
	var cal_a := Vector2.ZERO
	var cal_b := Vector2.ZERO

	func _physics_process(_delta: float) -> void:
		tick += 1
		phase_tick += 1
		var p = game.player
		if release_jump_at == tick:
			_hold("jump", false)
		if game.state != last_state:
			_event("state", {"from": last_state, "to": game.state, "reason": game.death_reason})
			last_state = game.state
		match phase:
			"menu":
				if phase_tick == 150: _tap("confirm")
				if game.state == game.State.PLAYING: _go("taxi_attempt")
			"taxi_attempt":
				# Run right, hop the first step, and do NOT jump the parked taxi.
				_hold("move_right", true)
				if p.position.x >= 138.0 and next_jump == 0 and p.is_on_floor():
					_tap("jump"); next_jump = 1
				if game.state == game.State.DYING:
					_hold("move_right", false); _go("wait_respawn_1")
			"wait_respawn_1":
				if game.state == game.State.PLAYING and phase_tick > 5: _go("look_around")
			"look_around":
				# Face left, stand, face right: shows both facings and idle.
				_hold("move_left", phase_tick > 90 and phase_tick <= 108)
				if phase_tick == 250: _hold("move_right", true)
				if phase_tick == 260: _hold("move_right", false)
				if phase_tick == 300: _tap("pause"); _go("paused")
			"paused":
				if phase_tick == 210: _tap("confirm")
				if phase_tick == 240: _hold("move_right", true)
				if phase_tick == 290:
					_hold("move_right", false); _tap("restart"); _go("after_restart")
			"after_restart":
				if phase_tick == int(OS.get_environment("NOZIP_WAIT") if OS.get_environment("NOZIP_WAIT") != "" else "100"): _start_route(NOZIP_JUMPS, []); _go("nozip_attempt")
			"nozip_attempt":
				_forgiveness_attempt()
				if game.state == game.State.DYING:
					_hold("move_right", false); _go("wait_respawn_2")
			"wait_respawn_2":
				# Start the clean run on the respawn tick itself so traffic timing
				# matches the tested route (both begin at attempt time 0).
				if game.state == game.State.PLAYING:
					_start_route(ROUTE_JUMPS, ROUTE_ZIPS); _go("clean_route"); _route_step()
			"clean_route":
				_route_step()
				if game.state == game.State.DYING:
					failed = "clean route died: " + game.death_reason; _go("done")
				elif game.state == game.State.COMPLETE:
					_hold("move_right", false); _go("complete_hold")
			"complete_hold":
				# Calibrate window->HUD mapping from two warped points, then aim.
				if phase_tick == 396: Input.warp_mouse(Vector2(100, 100))
				if phase_tick == 399: cal_a = game.hud.get_local_mouse_position(); Input.warp_mouse(Vector2(500, 500))
				if phase_tick == 402: cal_b = game.hud.get_local_mouse_position()
				if phase_tick == 405: _mouse_move()
				if phase_tick == 420: _mouse_click()
				if phase_tick > 420 and game.state == game.State.PLAYING: _go("replay")
				if phase_tick == 440:
					_event("mouse_click_failed", {}); _tap("confirm"); _go("replay")
			"replay":
				if phase_tick == 120: _tap("pause")
				if phase_tick == 210: _tap("menu"); _go("main_menu")
			"main_menu":
				if phase_tick == 120: _go("done")
			"done":
				if phase_tick == 2:
					_event("result", {"ok": failed == "", "failed": failed, "retries": game.deaths})
					for a in held.keys(): _hold(a, false)
					tree_ref.finish(failed)

	## Attempt 3: coyote jump off the Queens gap edge, spend the web-zip, then a
	## buffered press just before landing; afterwards ground jumps only, so the
	## first skyscraper is out of reach.
	func _forgiveness_attempt() -> void:
		var p = game.player
		var on_floor: bool = p.is_on_floor()
		_hold("move_right", true)
		match sub:
			0:
				if next_jump < 2 and p.position.x >= [138.0, 292.0][next_jump] and on_floor:
					_tap("jump"); next_jump += 1
				elif next_jump == 2 and was_floor and not on_floor and p.position.x > 440.0:
					mark_tick = tick; sub = 1
					_event("left_floor", {"note": "walked off the gap edge without jumping"})
			1:
				if tick == mark_tick + 4:
					jumps_seen = p.jumps
					_event("coyote_press", {"ticks_after_leaving_floor": 4, "on_floor": on_floor, "coyote_ticks": p.tuning.coyote_ticks})
					_tap("jump"); sub = 2
			2:
				if p.jumps > jumps_seen:
					_event("coyote_jump_fired", {"jumps": p.jumps}); jumps_seen = p.jumps; sub = 3
			3:
				if release_jump_at < tick and not on_floor and p.velocity.y >= -30.0:
					_tap("jump"); sub = 4
					_event("web_zip", {"note": "spends the one air jump so the next press can buffer"})
			4:
				if release_jump_at < tick and not on_floor and p.velocity.y > 0.0 and p.position.y > 297.0:
					mark_tick = tick; jumps_seen = p.jumps; sub = 5
					_event("buffer_press", {"on_floor": on_floor, "air_jumps_used": p.air_jumps_used, "buffer_ticks": p.tuning.buffer_ticks})
					_tap("jump")
			5:
				if p.jumps > jumps_seen:
					_event("buffered_jump_fired", {"ticks_after_press": tick - mark_tick}); sub = 6
					jumps = [548.0, 625.0]; next_jump = 0
			6:
				if next_jump < jumps.size() and p.position.x >= jumps[next_jump] and on_floor:
					_tap("jump"); next_jump += 1
		was_floor = on_floor

	func _start_route(j: Array, z: Array) -> void:
		jumps = j; zips = z; next_jump = 0; next_zip = 0

	func _route_step() -> void:
		var p = game.player
		_hold("move_right", true)
		if next_jump < jumps.size() and p.position.x >= jumps[next_jump] and p.is_on_floor():
			_tap("jump"); next_jump += 1
		elif next_zip < zips.size() and p.position.x >= zips[next_zip] and not p.is_on_floor() and release_jump_at < tick:
			_tap("jump"); next_zip += 1; _event("web_zip", {})

	## Real mouse events aimed at the centre of the modal's ENTER button
	## (HUD rect 220,198 200x34 in the 640x360 canvas), scaled to the window.
	func _button_pos() -> Vector2:
		# Invert the measured affine map (window px -> HUD canvas px) for the button centre.
		var scale := Vector2(400.0, 400.0) / (cal_b - cal_a)
		return Vector2(100, 100) + (Vector2(320.0, 215.0) - cal_a) * scale

	func _mouse_move() -> void:
		# The HUD reads the real cursor, so move the real cursor into the button.
		Input.warp_mouse(_button_pos())
		_event("input", {"action": "mouse_warp", "window_pos": str(_button_pos()), "calibration": [str(cal_a), str(cal_b)]})

	func _mouse_click() -> void:
		for pressed in [true, false]:
			var ev := InputEventMouseButton.new()
			ev.button_index = MOUSE_BUTTON_LEFT
			ev.pressed = pressed
			ev.position = _button_pos(); ev.global_position = ev.position
			Input.parse_input_event(ev)
		_event("input", {"action": "mouse_left_click", "window_pos": str(_button_pos()), "hud_local": str(game.hud.get_local_mouse_position())})

	func _go(name: String) -> void:
		_event("phase", {"phase": name})
		phase = name; phase_tick = 0

	func _tap(action: String) -> void:
		if action == "jump":
			# Jump is polled by the player: hold it for three physics ticks.
			_hold(action, true)
			release_jump_at = tick + 3
			return
		# Menu/pause/retry are handled in _unhandled_input, so send real events.
		for pressed in [true, false]:
			var ev := InputEventAction.new()
			ev.action = action
			ev.pressed = pressed
			Input.parse_input_event(ev)
		_event("input", {"action": action, "pressed": true, "via": "InputEventAction tap"})

	func _hold(action: String, pressed: bool) -> void:
		if held.get(action, false) == pressed:
			return
		held[action] = pressed
		if pressed: Input.action_press(action)
		else: Input.action_release(action)
		_event("input", {"action": action, "pressed": pressed})

	func _event(kind: String, data: Dictionary) -> void:
		var p = game.player
		var row := {"tick": tick, "t_s": snappedf(tick / 60.0, 0.001), "kind": kind,
			"x": snappedf(p.position.x, 0.1), "y": snappedf(p.position.y, 0.1),
			"state": game.state, "retries": game.deaths, "phase": phase}
		row.merge(data)
		tree_ref.write_log(row)

func _initialize() -> void:
	log_file = FileAccess.open(ProjectSettings.globalize_path("res://").path_join("../capture/" + LOG_NAME).simplify_path(), FileAccess.WRITE)
	game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	driver = Driver.new()
	driver.tree_ref = self
	driver.game = game
	driver.process_physics_priority = -100   # inputs land before the player reads them
	root.add_child(driver)

func write_log(row: Dictionary) -> void:
	log_file.store_line(JSON.stringify(row))
	log_file.flush()

func finish(failed: String) -> void:
	log_file.close()
	if failed != "":
		printerr("CAPTURE FAILED: " + failed)
		quit(1)
	else:
		print("CAPTURE OK")
		quit(0)
