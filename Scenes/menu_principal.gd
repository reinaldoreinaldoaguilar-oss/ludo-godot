extends Control
## Menú principal: jugar (con configuración de partida), partida rápida,
## reglas, gestor de preguntas, ajustes y estadísticas históricas.

const LEVEL_SCENE := "res://Levels/Level_MainGamePlay.tscn"
const COLORES_POR_CANTIDAD := {
	2: [GameManager.PlayerColor.Green, GameManager.PlayerColor.Blue],
	3: [GameManager.PlayerColor.Green, GameManager.PlayerColor.Yellow, GameManager.PlayerColor.Blue],
	4: [GameManager.PlayerColor.Green, GameManager.PlayerColor.Yellow, GameManager.PlayerColor.Blue, GameManager.PlayerColor.Red],
}

var menu_box: VBoxContainer

func _ready() -> void:
	theme = UITheme.get_theme()
	AudioManager.play_music()
	construir_menu()

func construir_menu() -> void:
	var center := CenterContainer.new()
	center.anchor_left = 0.62
	center.anchor_right = 1.0
	center.anchor_bottom = 1.0
	add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(340, 0)
	menu_box = VBoxContainer.new()
	menu_box.add_theme_constant_override("separation", 10)
	panel.add_child(menu_box)
	center.add_child(panel)
	var jugar := UIKit.button("JUGAR", abrir_configuracion, 58)
	jugar.add_theme_font_size_override("font_size", 26)
	menu_box.add_child(jugar)
	var rapida := UIKit.button("Partida rápida vs bots", partida_rapida)
	UITheme.colored_button(rapida, Color("1e90ff"))
	menu_box.add_child(rapida)
	for item in [["Reglas", func(): PanelReglas.abrir(self)],
			["Gestionar preguntas", abrir_gestor_preguntas],
			["Ajustes", func(): PanelAjustes.abrir(self)],
			["Salir", func(): get_tree().quit()]]:
		var b := UIKit.button(item[0], item[1], 44)
		UITheme.colored_button(b, Color(1, 1, 1, 0.14))
		menu_box.add_child(b)
	var h := GameManager.historial
	var porcentaje := 0 if h["trivia_total"] == 0 else roundi(100.0 * h["trivia_ok"] / h["trivia_total"])
	var stats := UIKit.label("Partidas: %d   ·   Victorias: %d   ·   Trivia: %d%%" % [h["partidas"], h["victorias_humanas"], porcentaje], 14, UITheme.TEXT_MUTED, 700)
	stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	menu_box.add_child(stats)
	UITheme.pop_in.call_deferred(panel, 0.5)

func partida_rapida() -> void:
	GameManager.configurar_partida_rapida(true)
	GameManager.trivia_activa = true
	GameManager.modo_victoria = GameManager.VictoryMode.Rapida
	iniciar()

func iniciar() -> void:
	GameManager.guardar_ultima_partida()
	get_tree().change_scene_to_file(LEVEL_SCENE)

# ---------------------------------------------------------------- Configuración de partida

func abrir_configuracion() -> void:
	var layer := UIKit.overlay(self)
	var box := UIKit.centered_box(layer, 640, 8)
	box.add_child(UIKit.title("Nueva partida", 26))

	var previa := GameManager.cargar_ultima_partida()
	var filas: Dictionary = {} # color -> {fila, nombre, tipo}
	var cantidad := {"valor": 4}
	if not previa.is_empty() and previa["jugadores"].size() in [2, 3, 4]:
		cantidad["valor"] = previa["jugadores"].size()
	var config := {
		"dificultad": previa.get("dificultad", GameManager.Difficulty.Normal),
		"modo": previa.get("modo_victoria", GameManager.VictoryMode.Completa),
		"trivia": previa.get("trivia", true),
	}

	var actualizar_filas := func():
		for color in filas:
			filas[color]["fila"].visible = COLORES_POR_CANTIDAD[cantidad["valor"]].has(color)

	box.add_child(UIKit.row([
		UIKit.expand(UIKit.label("Número de jugadores", 18)),
		UIKit.option(["2 jugadores", "3 jugadores", "4 jugadores"], cantidad["valor"] - 2, func(i):
			cantidad["valor"] = i + 2
			actualizar_filas.call()),
	]))
	for color in GameManager.TURN_ORDER:
		var anterior := {}
		for j in previa.get("jugadores", []):
			if j["color"] == color:
				anterior = j
		var dot := Panel.new()
		dot.custom_minimum_size = Vector2(22, 22)
		dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		dot.add_theme_stylebox_override("panel", UITheme.box(GameManager.COLOR_VALUES[color], 11, Color.TRANSPARENT, 0, 0))
		var nombre := LineEdit.new()
		nombre.text = anterior.get("nombre", "Jugador " + GameManager.COLOR_NAMES[color])
		nombre.max_length = 16
		nombre.custom_minimum_size = Vector2(0, 36)
		var es_bot: bool = anterior.get("es_bot", color != GameManager.PlayerColor.Green)
		var tipo := UIKit.option(["Humano", "Bot"], 1 if es_bot else 0, func(_i): pass)
		tipo.custom_minimum_size = Vector2(140, 36)
		var fila := UIKit.row([dot, UIKit.expand(nombre), tipo])
		filas[color] = {"fila": fila, "nombre": nombre, "tipo": tipo}
		box.add_child(fila)
	actualizar_filas.call()

	var dificultad := UIKit.option(["Bots: Fácil", "Bots: Normal", "Bots: Difícil"], config["dificultad"], func(i): config["dificultad"] = i)
	var modo := UIKit.option(["Victoria rápida", "Ranking completo"], config["modo"], func(i): config["modo"] = i)
	box.add_child(UIKit.row([UIKit.expand(dificultad), UIKit.expand(modo)]))
	var trivia := CheckButton.new()
	trivia.text = "Trivia activada"
	trivia.add_theme_font_size_override("font_size", 17)
	trivia.button_pressed = config["trivia"]
	box.add_child(trivia)

	var error := UIKit.label("", 15, Color("ff6b81"))
	error.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(error)
	var volver := UIKit.button("Volver", layer.queue_free)
	UITheme.colored_button(volver, Color(1, 1, 1, 0.14))
	var empezar := UIKit.button("¡Empezar!", func():
		var lista: Array[Dictionary] = []
		for color in COLORES_POR_CANTIDAD[cantidad["valor"]]:
			var n: String = filas[color]["nombre"].text.strip_edges()
			lista.append({
				"color": color,
				"nombre": n if n != "" else GameManager.COLOR_NAMES[color],
				"es_bot": filas[color]["tipo"].selected == 1,
			})
		if lista.all(func(j): return j["es_bot"]):
			error.text = "Debe haber al menos un jugador humano."
			return
		GameManager.configurar_partida(lista, config["dificultad"], config["modo"], trivia.button_pressed)
		iniciar())
	box.add_child(UIKit.row([UIKit.expand(volver), UIKit.expand(empezar)]))
	UITheme.pop_in(box.get_parent())

# ---------------------------------------------------------------- Gestor de preguntas

func abrir_gestor_preguntas() -> void:
	var layer := UIKit.overlay(self)
	var box := UIKit.centered_box(layer, 960, 10)
	box.add_child(UIKit.title("Banco de preguntas", 26))
	var categorias: Array = BasePreguntas.categorias()
	var estado := {"cat": categorias[0], "lista": []}

	# Columna izquierda: lista de preguntas
	var lista := ItemList.new()
	lista.custom_minimum_size = Vector2(440, 290)
	lista.add_theme_font_size_override("font_size", 15)
	lista.add_theme_stylebox_override("panel", UITheme.box(Color(1, 1, 1, 0.06), 12, Color.TRANSPARENT, 0, 8))
	var detalle := UIKit.label("", 14, UITheme.TEXT_MUTED, 600)
	detalle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detalle.custom_minimum_size = Vector2(440, 40)
	var borrar := UIKit.button("Eliminar pregunta propia", func(): pass, 40)
	borrar.disabled = true
	var contador := UIKit.label("", 14, UITheme.TEXT_MUTED, 700)

	var refrescar := func():
		lista.clear()
		estado["lista"] = BasePreguntas.preguntas_de(estado["cat"])
		for p in estado["lista"]:
			lista.add_item(("★ " if p.get("propia", false) else "") + p["pregunta"])
		contador.text = "%d preguntas en esta categoría · ★ = agregada por ti" % estado["lista"].size()
		detalle.text = ""
		borrar.disabled = true
	lista.item_selected.connect(func(i):
		var p: Dictionary = estado["lista"][i]
		detalle.text = "Respuesta: %s   ·   %d pts" % [p["opciones"][int(p["correcta"])], int(p.get("bonus", 1))]
		borrar.disabled = not p.get("propia", false))
	borrar.pressed.connect(func():
		var sel := lista.get_selected_items()
		if sel.size() > 0:
			BasePreguntas.eliminar_pregunta(estado["cat"], estado["lista"][sel[0]]["pregunta"])
			refrescar.call())
	var nombres := categorias.map(func(c): return BasePreguntas.nombres_categoria[c])
	var selector := UIKit.option(nombres, 0, func(i):
		estado["cat"] = categorias[i]
		refrescar.call())
	var izquierda := VBoxContainer.new()
	izquierda.add_theme_constant_override("separation", 8)
	for c in [selector, lista, contador, detalle, borrar]:
		izquierda.add_child(c)

	# Columna derecha: formulario para agregar
	var derecha := VBoxContainer.new()
	derecha.add_theme_constant_override("separation", 8)
	derecha.custom_minimum_size = Vector2(440, 0)
	derecha.add_child(UIKit.label("Agregar pregunta a la categoría elegida", 17, UITheme.TEXT, 800))
	var pregunta := LineEdit.new()
	pregunta.placeholder_text = "Escribe la pregunta"
	derecha.add_child(pregunta)
	var opciones: Array[LineEdit] = []
	for letra in ["A", "B", "C", "D"]:
		var o := LineEdit.new()
		o.placeholder_text = "Opción " + letra
		opciones.append(o)
		derecha.add_child(o)
	var correcta := UIKit.option(["Correcta: A", "Correcta: B", "Correcta: C", "Correcta: D"], 0, func(_i): pass)
	var bonus := SpinBox.new()
	bonus.min_value = 1
	bonus.max_value = 5
	bonus.value = 2
	bonus.suffix = "pts"
	derecha.add_child(UIKit.row([UIKit.expand(correcta), bonus]))
	var aviso := UIKit.label("", 15, Color("2ed573"))
	derecha.add_child(UIKit.button("Agregar pregunta", func():
		var err := BasePreguntas.agregar_pregunta(estado["cat"], pregunta.text,
			opciones.map(func(o): return o.text), correcta.selected, int(bonus.value))
		if err != "":
			aviso.add_theme_color_override("font_color", Color("ff6b81"))
			aviso.text = err
			return
		aviso.add_theme_color_override("font_color", Color("2ed573"))
		aviso.text = "¡Pregunta agregada!"
		pregunta.text = ""
		for o in opciones:
			o.text = ""
		refrescar.call(), 44))
	derecha.add_child(aviso)
	var cerrar := UIKit.button("Cerrar", layer.queue_free, 44)
	UITheme.colored_button(cerrar, Color(1, 1, 1, 0.14))
	derecha.add_child(cerrar)

	box.add_child(UIKit.row([izquierda, derecha], 24))
	refrescar.call()
	UITheme.pop_in(box.get_parent())
