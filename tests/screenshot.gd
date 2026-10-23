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
	var accion: String = args[4] if args.size() > 4 else ""
	var scene: Node = load(scene_path).instantiate()
	add_child(scene)
	await get_tree().create_timer(seconds).timeout
	match accion:
		"config": scene.abrir_configuracion()
		"preguntas": scene.abrir_gestor_preguntas()
		"reglas": PanelReglas.abrir(scene)
		"trivia": get_tree().get_first_node_in_group("Trivia").preguntar()
		"pausa": get_tree().get_first_node_in_group("HUD").toggle_pause()
		"fin":
			var board = get_tree().get_first_node_in_group("Tablero")
			board.stats[0]["capturas"] = 3
			board.finish_game()
	if accion != "":
		await get_tree().create_timer(1.6).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(out)
	get_tree().quit()
