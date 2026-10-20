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

# Base de datos de preguntas (NUEVO)
var banco_preguntas = [
	# --- ESTRUCTURAS DINÁMICAS ---
	{"tema": "Estructuras Dinámicas", "pregunta": "¿Qué es una Pila (Stack)?", "respuesta": "Una estructura LIFO (Last In, First Out). El último elemento en entrar es el primero en salir."},
	{"tema": "Estructuras Dinámicas", "pregunta": "¿Qué es una Cola (Queue)?", "respuesta": "Una estructura FIFO (First In, First Out). El primer elemento en entrar es el primero en salir."},
	{"tema": "Estructuras Dinámicas", "pregunta": "¿Qué diferencia una lista enlazada de un arreglo estático?", "respuesta": "La lista crece dinámicamente en memoria; el arreglo tiene un tamaño fijo definido desde el principio."},
	{"tema": "Estructuras Dinámicas", "pregunta": "¿Qué guarda el 'nodo' de una lista enlazada simple?", "respuesta": "Guarda el valor (dato) y un puntero (referencia) al siguiente nodo."},
	{"tema": "Estructuras Dinámicas", "pregunta": "¿Qué es una lista doblemente enlazada?", "respuesta": "Una lista donde cada nodo tiene referencias tanto al nodo siguiente como al nodo anterior."},
	{"tema": "Estructuras Dinámicas", "pregunta": "¿Qué es un Árbol Binario?", "respuesta": "Una estructura jerárquica donde cada nodo tiene como máximo dos hijos (izquierdo y derecho)."},
	{"tema": "Estructuras Dinámicas", "pregunta": "¿Qué es un Grafo?", "respuesta": "Un conjunto de nodos (vértices) conectados por enlaces (aristas), útil para representar redes."},
	{"tema": "Estructuras Dinámicas", "pregunta": "¿Qué sucede en un 'Desbordamiento de Pila' (Stack Overflow)?", "respuesta": "Ocurre cuando el programa intenta usar más espacio de memoria en la pila de llamadas del que está disponible."},

	# --- CULTURA GENERAL ---
	{"tema": "Cultura General", "pregunta": "¿Cuál es el río más largo del mundo?", "respuesta": "El río Amazonas."},
	{"tema": "Cultura General", "pregunta": "¿Quién pintó la famosa obra de la Mona Lisa?", "respuesta": "Leonardo da Vinci."},
	{"tema": "Cultura General", "pregunta": "¿Cuál es el planeta más grande de nuestro sistema solar?", "respuesta": "Júpiter."},
	{"tema": "Cultura General", "pregunta": "¿En qué año llegó el hombre a la Luna por primera vez?", "respuesta": "En el año 1969."},
	{"tema": "Cultura General", "pregunta": "¿Cuál es el hueso más largo del cuerpo humano?", "respuesta": "El fémur."},
	{"tema": "Cultura General", "pregunta": "¿Cuántos estados conforman políticamente a Venezuela?", "respuesta": "23 estados y el Distrito Capital."},
	{"tema": "Cultura General", "pregunta": "¿Cuál es el océano más grande del mundo?", "respuesta": "El Océano Pacífico."},
	{"tema": "Cultura General", "pregunta": "¿Cuál es el símbolo químico del oro?", "respuesta": "Au."}
]

func _ready():
	# Asegurarnos de que el menú principal se vea y los demás estén ocultos al inicio
	menu_botones.show()
	menu_modos.hide()
	panel_preguntas.hide() # Ocultamos el panel de preguntas al inicio (NUEVO)
	
	# Conectar botones principales a sus funciones
	btn_jugar.pressed.connect(_on_btn_jugar_pressed)
	btn_preguntas.pressed.connect(_on_btn_preguntas_pressed)
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
	
	# Cargamos las preguntas automáticamente en el cuadro de texto (NUEVO)
	for p in banco_preguntas:
		lbl_preguntas.text += "[" + p["tema"] + "] " + p["pregunta"] + "\n"
		lbl_preguntas.text += "R: " + p["respuesta"] + "\n\n"

func _on_btn_salir_pressed():
	print("Saliendo del juego...")
	get_tree().quit()

# --- LÓGICA MENÚ DE MODOS ---

func _on_btn_local_pressed():
	print("Iniciando partida Local con amigos...")
	GameManager.modo_contra_bots = false # Apaga los bots
	get_tree().change_scene_to_file("res://Levels/Level_MainGamePlay.tscn")

func _on_btn_bots_pressed():
	print("Iniciando partida contra Bots...")
	GameManager.modo_contra_bots = true # Enciende los bots
	get_tree().change_scene_to_file("res://Levels/Level_MainGamePlay.tscn")

func _on_btn_volver_pressed():
	print("Volviendo al menú principal...")
	menu_modos.hide()
	menu_botones.show()

# --- LÓGICA GESTOR DE PREGUNTAS (NUEVO) ---

func _on_btn_cerrar_panel_pressed():
	print("Cerrando Gestor de Preguntas...")
	panel_preguntas.hide()
