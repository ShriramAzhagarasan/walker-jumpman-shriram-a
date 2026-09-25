extends SceneTree
## Renders close-ups of each character and a few scene frames for art review.
## Run with a display (not --headless):
##   Godot --path godot -s res://tests/capture_art.gd
const Game = preload("res://game/session.gd")
var game: Node2D
var output: String

func _initialize() -> void:
	call_deferred("run")

func step(n: int = 1) -> void:
	for i in range(n):
		await physics_frame
		await process_frame

func capture(label: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(output + "/" + label + ".png")
	print("captured " + label)

func shot(label: String, at: Vector2, zoom: float) -> void:
	var was_playing: bool = game.state == Game.State.PLAYING and zoom > 1.0
	if was_playing:
		game.set_paused(true)
	game.camera.position = at
	game.camera.zoom = Vector2(zoom, zoom)
	game.hud.visible = zoom <= 1.0
	await step(2)
	await capture(label)
	game.camera.zoom = Vector2.ONE
	game.hud.visible = true
	if was_playing:
		game.set_paused(false)

func run() -> void:
	output = ProjectSettings.globalize_path("res://../evidence/art")
	DirAccess.make_dir_recursive_absolute(output)
	game = Game.new()
	game.test_mode = true
	root.add_child(game)
	await step(3)
	game.start_session()
	game.player.test_control = true
	# Spider-Man running, close-up.
	game.player.test_axis = 1
	await step(20)
	game.player.test_axis = 1
	await shot("spidey-run", game.player.position + Vector2(0, -14), 7.0)
	# Spider-Man jumping with the web to the ceiling.
	game.player.test_jump_pressed = true
	await step(10)
	await shot("spidey-jump-scene", Vector2(game.player.position.x + 100, 180), 1.0)
	await shot("spidey-jump", game.player.position + Vector2(0, -14), 7.0)
	game.player.test_jump_pressed = true
	await step(6)
	await shot("spidey-webzip-scene", Vector2(game.player.position.x + 100, 180), 1.0)
	game.player.test_axis = 0
	await step(60)
	await shot("spidey-idle", game.player.position + Vector2(0, -14), 7.0)
	game.player.enabled = false
	await shot("vulture", Vector2(300 + sin(game.anim_time * 0.45) * 150.0, 150), 3.5)
	await shot("goblin", Vector2(760 + sin(game.anim_time * 0.35 + 1.0) * 170.0, 130), 3.5)
	await shot("doc-ock", Vector2(1262, 205), 3.5)
	await shot("taxi-static", Vector2(332, 305), 6.0)
	for x in [320, 760, 1300, 1700, 2150]:
		game.player.position = Vector2(x - 80, 250)
		await shot("scene-%d" % x, Vector2(x, 180), 1.0)
	quit()
