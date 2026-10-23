extends Control
## Ventana de trivia con temporizador, categoría, puntos y respuesta visual.
## Uso: var r = await ventana.preguntar()  ->  {"correcta": bool, "puntos": int}

signal respondido(es_correcta: bool)

const TIEMPO := 15.0
const PAUSA_RESULTADO := 1.3
const COLOR_OK := Color("2ed573")
const COLOR_MAL := Color("ff4757")

var texto_pregunta: Label
var etiqueta_categoria: Label
var etiqueta_puntos: Label
var etiqueta_tiempo: Label
var barra_tiempo: ProgressBar
var resultado: Label
var botones: Array[Button] = []
var panel: PanelContainer

var indice_correcto: int = 0
var bonus_actual: int = 0
var tiempo_restante: float = 0.0
var esperando: bool = false

func _enter_tree() -> void:
	add_to_group("Trivia")

func _ready() -> void:
	theme = UITheme.get_theme()
	construir()
	hide()
	set_process(false)

func construir() -> void:
	UIKit.overlay(self, 0.65)
	var box := UIKit.centered_box(self, 660, 14)
	panel = box.get_parent()
	panel.add_theme_stylebox_override("panel", UITheme.box(Color(0.09, 0.1, 0.16, 0.98), 24, Color("ffd32a"), 2, 24))
	etiqueta_categoria = UIKit.label("", 15, Color("ffd32a"), 800)
	etiqueta_puntos = UIKit.label("", 15, Color("ffd32a"), 800)
	etiqueta_puntos.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	box.add_child(UIKit.row([UIKit.expand(etiqueta_categoria), etiqueta_puntos]))
	texto_pregunta = UIKit.label("", 23, UITheme.TEXT, 800)
	texto_pregunta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	texto_pregunta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texto_pregunta.custom_minimum_size = Vector2(600, 70)
	box.add_child(texto_pregunta)
	barra_tiempo = ProgressBar.new()
	barra_tiempo.show_percentage = false
	barra_tiempo.custom_minimum_size = Vector2(0, 10)
	barra_tiempo.max_value = TIEMPO
	etiqueta_tiempo = UIKit.label("", 15, UITheme.TEXT_MUTED, 800)
	box.add_child(UIKit.row([UIKit.expand(barra_tiempo), etiqueta_tiempo]))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	for i in 4:
		var b := Button.new()
		b.custom_minimum_size = Vector2(300, 64)
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		b.add_theme_font_size_override("font_size", 17)
		UITheme.colored_button(b, Color("3d4459"))
		b.pressed.connect(evaluar_respuesta.bind(i))
		botones.append(b)
		grid.add_child(b)
	box.add_child(grid)
	resultado = UIKit.label("", 20, UITheme.TEXT, 900)
	resultado.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(resultado)

## Muestra una pregunta (categoría al azar si no se indica) y espera la respuesta.
func preguntar(categoria: String = "") -> Dictionary:
	cargar_pregunta(categoria)
	show()
	UITheme.pop_in(panel)
	var es_correcta: bool = await respondido
	return {"correcta": es_correcta, "puntos": bonus_actual if es_correcta else 0}

func cargar_pregunta(categoria: String = "") -> void:
	var datos: Dictionary = BasePreguntas.pregunta_aleatoria(categoria)
	texto_pregunta.text = datos["pregunta"]
	etiqueta_categoria.text = datos["categoria_nombre"].to_upper()
	etiqueta_puntos.text = "+%d pts" % datos["bonus"]
	# Las opciones se barajan para que la respuesta no esté siempre en el mismo lugar.
	var orden := [0, 1, 2, 3]
	orden.shuffle()
	for i in 4:
		var b := botones[i]
		b.text = datos["opciones"][orden[i]]
		b.disabled = false
		b.remove_theme_stylebox_override("disabled")
	indice_correcto = orden.find(datos["correcta"])
	bonus_actual = datos["bonus"]
	resultado.text = ""
	tiempo_restante = TIEMPO
	esperando = true
	set_process(true)

func _process(delta: float) -> void:
	tiempo_restante -= delta
	barra_tiempo.value = maxf(tiempo_restante, 0.0)
	etiqueta_tiempo.text = "%ds" % ceili(maxf(tiempo_restante, 0.0))
	var fill: StyleBoxFlat = barra_tiempo.get_theme_stylebox("fill").duplicate()
	fill.bg_color = COLOR_OK if tiempo_restante > 5.0 else COLOR_MAL
	barra_tiempo.add_theme_stylebox_override("fill", fill)
	if tiempo_restante <= 0.0:
		evaluar_respuesta(-1)

## boton_presionado = -1 significa que se acabó el tiempo.
func evaluar_respuesta(boton_presionado: int) -> void:
	if not esperando:
		return
	esperando = false
	set_process(false)
	var es_correcta := boton_presionado == indice_correcto
	for i in 4:
		botones[i].disabled = true
		var c := Color(1, 1, 1, 0.08)
		if i == indice_correcto:
			c = COLOR_OK
		elif i == boton_presionado:
			c = COLOR_MAL
		botones[i].add_theme_stylebox_override("disabled", UITheme.box(c, 16, Color(1, 1, 1, 0.2), 2, 12))
	if es_correcta:
		resultado.text = "¡Correcto! +%d pts" % bonus_actual
		resultado.add_theme_color_override("font_color", COLOR_OK)
		AudioManager.play("correct")
	else:
		resultado.text = "¡Se acabó el tiempo!" if boton_presionado == -1 else "Incorrecto"
		resultado.add_theme_color_override("font_color", COLOR_MAL)
		AudioManager.play("wrong")
	await get_tree().create_timer(PAUSA_RESULTADO, false).timeout
	hide()
	respondido.emit(es_correcta)
