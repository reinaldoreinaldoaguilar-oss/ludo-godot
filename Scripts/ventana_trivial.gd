extends Control
## Ventana de trivia. Uso: var r = await ventana.preguntar()  ->  {"correcta": bool, "puntos": int}

signal respondido(es_correcta: bool)

@onready var texto_pregunta: Label = $Panel/TextoPregunta
@onready var botones: Array[Button] = [
	$Panel/VBoxContainer/Button, $Panel/VBoxContainer/Button2,
	$Panel/VBoxContainer/Button3, $Panel/VBoxContainer/Button4,
]

var indice_correcto: int = 0
var bonus_actual: int = 0

func _enter_tree() -> void:
	add_to_group("Trivia")

func _ready() -> void:
	hide()
	for i in botones.size():
		botones[i].pressed.connect(evaluar_respuesta.bind(i))

## Muestra una pregunta (categoría al azar si no se indica) y espera la respuesta.
func preguntar(categoria: String = "") -> Dictionary:
	cargar_pregunta(categoria)
	show()
	var es_correcta: bool = await respondido
	return {"correcta": es_correcta, "puntos": bonus_actual if es_correcta else 0}

func cargar_pregunta(categoria: String = "") -> void:
	var datos: Dictionary = BasePreguntas.pregunta_aleatoria(categoria)
	texto_pregunta.text = datos["pregunta"]
	for i in botones.size():
		botones[i].text = datos["opciones"][i]
	indice_correcto = datos["correcta"]
	bonus_actual = datos.get("bonus", 1)

func evaluar_respuesta(boton_presionado: int) -> void:
	hide()
	respondido.emit(boton_presionado == indice_correcto)
