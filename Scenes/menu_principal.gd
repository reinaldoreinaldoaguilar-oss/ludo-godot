extends Control

# Referencias a las "carpetas" de botones
@onready var menu_botones = $MenuBotones
@onready var menu_modos = $MenuModos

# Botones Principales
@onready var btn_jugar = $MenuBotones/BtnJugar
@onready var btn_preguntas = $MenuBotones/BtnPreguntas
@onready var btn_salir = $MenuBotones/BtnSalir

# Botones de Modos
@onready var btn_local = $MenuModos/BtnLocal
@onready var btn_bots = $MenuModos/BtnBots
@onready var btn_volver = $MenuModos/BtnVolver

# Nodos del Panel de Preguntas (NUEVO)
@onready var panel_preguntas = $PanelPreguntas
@onready var lbl_preguntas = $PanelPreguntas/RichTextLabel
@onready var btn_cerrar_panel = $PanelPreguntas/BtnCerrarPanel


func _ready():
	# Asegurarnos de que el menú principal se vea y los demás estén ocultos al inicio
	menu_botones.show()
	menu_modos.hide()
	panel_preguntas.hide() # Ocultamos el panel de preguntas al inicio (NUEVO)
	
	# Conectar botones principales a sus funciones
	btn_jugar.pressed.connect(_on_btn_jugar_pressed)
	btn_salir.pressed.connect(_on_btn_salir_pressed)
	
	# Conectar botones de modo a sus funciones
	btn_local.pressed.connect(_on_btn_local_pressed)
	btn_bots.pressed.connect(_on_btn_bots_pressed)
	btn_volver.pressed.connect(_on_btn_volver_pressed)
	
	# Conectar el botón de cerrar el panel de preguntas (NUEVO)
	btn_cerrar_panel.pressed.connect(_on_btn_cerrar_panel_pressed)

# --- LÓGICA MENÚ PRINCIPAL ---

func _on_btn_jugar_pressed():
	print("Mostrando modos de juego...")
	# Oculta el menú principal y muestra la selección de modos
	menu_botones.hide()
	menu_modos.show()

func _on_btn_preguntas_pressed():
	print("Abriendo Gestor de Preguntas...")
	
	# Mostramos el panel (NUEVO)
	panel_preguntas.show()
	
	# Limpiamos y preparamos el título (NUEVO)
	lbl_preguntas.text = "--- BANCO DE PREGUNTAS ---\n\n"
	
	# Mostramos el mismo banco que usa la trivia del juego (Data/preguntas.json)
	for categoria in BasePreguntas.categorias():
		lbl_preguntas.text += "[" + BasePreguntas.nombres_categoria[categoria] + "]\n"
		for p in BasePreguntas.trivia[categoria]:
			lbl_preguntas.text += "• " + p["pregunta"] + "\n  R: " + p["opciones"][p["correcta"]] + "\n"
		lbl_preguntas.text += "\n"

func _on_btn_salir_pressed():
	print("Saliendo del juego...")
	get_tree().quit()

# --- LÓGICA MENÚ DE MODOS ---

func _on_btn_local_pressed():
	print("Iniciando partida Local con amigos...")
	GameManager.configurar_partida_rapida(false) # Todos humanos
	get_tree().change_scene_to_file("res://Levels/Level_MainGamePlay.tscn")

func _on_btn_bots_pressed():
	print("Iniciando partida contra Bots...")
	GameManager.configurar_partida_rapida(true) # Verde humano, resto bots
	get_tree().change_scene_to_file("res://Levels/Level_MainGamePlay.tscn")

func _on_btn_volver_pressed():
	print("Volviendo al menú principal...")
	menu_modos.hide()
	menu_botones.show()

# --- LÓGICA GESTOR DE PREGUNTAS (NUEVO) ---

func _on_btn_cerrar_panel_pressed():
	print("Cerrando Gestor de Preguntas...")
	panel_preguntas.hide()
