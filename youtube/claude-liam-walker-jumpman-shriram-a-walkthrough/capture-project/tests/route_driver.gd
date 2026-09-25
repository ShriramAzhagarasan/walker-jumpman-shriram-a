extends RefCounted
## Fixed input route through the real level. No position/velocity edits.
## Ground jumps fire at jump_marks; web-zip air jumps fire at air_marks while airborne.
var jump_marks: Array[float] = [138.0, 292.0, 424.0, 548.0, 625.0, 945.0, 1070.0, 1205.0, 1390.0, 1600.0, 1700.0, 1925.0, 2085.0, 2225.0]
var air_marks: Array[float] = [683.0, 1258.0, 1790.0]
var next_jump: int = 0
var next_air: int = 0

func step(player: CharacterBody2D) -> void:
	player.test_control = true
	player.test_axis = 1.0
	player.test_jump_held = false
	if next_jump < jump_marks.size() and player.position.x >= jump_marks[next_jump] and player.is_on_floor():
		player.test_jump_pressed = true
		next_jump += 1
	elif next_air < air_marks.size() and player.position.x >= air_marks[next_air] and not player.is_on_floor():
		player.test_jump_pressed = true
		next_air += 1
