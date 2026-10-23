extends Node
## Herramienta de desarrollo: abre una escena, espera y guarda una captura.
## godot res://tests/screenshot.tscn -- <escena> <segundos> <salida.png> [bots]

func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	var scene_path: String = args[0] if args.size() > 0 else "res://Scenes/menu_principal.tscn"
	var seconds: float = float(args[1]) if args.size() > 1 else 2.0
	var out: String = args[2] if args.size() > 2 else "/tmp/shot.png"
	if args.size() > 3 and args[3] == "bots":
		GameManager.configurar_partida_rapida(true)
		for j in GameManager.jugadores:
			j["es_bot"] = true
	var scene: Node = load(scene_path).instantiate()
	add_child(scene)
	await get_tree().create_timer(seconds).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(out)
	get_tree().quit()
