extends Node
## Autoload: banco de preguntas de la trivia.
## - Preguntas base: res://Data/preguntas.json (vienen con el juego).
## - Preguntas propias: user://preguntas_extra.json (se agregan desde el menú
##   "Gestionar preguntas" y se pueden borrar).

const RUTA_PREGUNTAS := "res://Data/preguntas.json"
const RUTA_EXTRA := "user://preguntas_extra.json"

## categoria_id -> Array de preguntas {pregunta, opciones[4], correcta, bonus, propia?}
var trivia: Dictionary = {}
var nombres_categoria: Dictionary = {}
var extra: Dictionary = {} # categoria_id -> Array de preguntas propias
var _recientes: Array[String] = [] # Evita repetir la misma pregunta seguido.

func _init() -> void:
	cargar(RUTA_PREGUNTAS)
	cargar_extra()

func cargar(ruta: String) -> void:
	var datos = JSON.parse_string(FileAccess.get_file_as_string(ruta))
	if typeof(datos) != TYPE_DICTIONARY or not datos.has("categorias"):
		push_error("No se pudo leer el banco de preguntas: " + ruta)
		return
	trivia.clear()
	for cat in datos["categorias"]:
		trivia[cat["id"]] = cat["preguntas"].filter(es_valida)
		nombres_categoria[cat["id"]] = cat["nombre"]

func cargar_extra() -> void:
	extra.clear()
	if not FileAccess.file_exists(RUTA_EXTRA):
		return
	var datos = JSON.parse_string(FileAccess.get_file_as_string(RUTA_EXTRA))
	if typeof(datos) != TYPE_DICTIONARY:
		return
	for cat in datos:
		if trivia.has(cat):
			extra[cat] = datos[cat].filter(es_valida)

func guardar_extra() -> void:
	var f := FileAccess.open(RUTA_EXTRA, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(extra, "\t"))

func es_valida(p) -> bool:
	if typeof(p) != TYPE_DICTIONARY or not p.has("pregunta") or str(p["pregunta"]).strip_edges() == "":
		return false
	var opciones = p.get("opciones", [])
	if typeof(opciones) != TYPE_ARRAY or opciones.size() != 4:
		return false
	var correcta := int(p.get("correcta", -1))
	return correcta >= 0 and correcta < 4

func categorias() -> Array:
	return trivia.keys()

## Preguntas base + propias de una categoría.
func preguntas_de(categoria: String) -> Array:
	var lista: Array = trivia.get(categoria, []).duplicate()
	for p in extra.get(categoria, []):
		var copia: Dictionary = p.duplicate()
		copia["propia"] = true
		lista.append(copia)
	return lista

func total_preguntas() -> int:
	var total := 0
	for cat in categorias():
		total += preguntas_de(cat).size()
	return total

## Agrega una pregunta propia. Devuelve "" si todo salió bien, o el motivo del error.
func agregar_pregunta(categoria: String, pregunta: String, opciones: Array, correcta: int, bonus: int) -> String:
	var nueva := {
		"pregunta": pregunta.strip_edges(),
		"opciones": opciones.map(func(o): return str(o).strip_edges()),
		"correcta": correcta,
		"bonus": clampi(bonus, 1, 5),
	}
	if not trivia.has(categoria):
		return "Categoría inválida."
	if nueva["pregunta"].length() < 5:
		return "Escribe una pregunta más completa."
	if nueva["opciones"].any(func(o): return o == ""):
		return "Completa las 4 opciones."
	if not es_valida(nueva):
		return "La pregunta no es válida."
	if not extra.has(categoria):
		extra[categoria] = []
	extra[categoria].append(nueva)
	guardar_extra()
	return ""

func eliminar_pregunta(categoria: String, texto: String) -> void:
	if extra.has(categoria):
		extra[categoria] = extra[categoria].filter(func(p): return p["pregunta"] != texto)
		guardar_extra()

## Devuelve una pregunta al azar (de la categoría indicada o de cualquiera).
func pregunta_aleatoria(categoria: String = "") -> Dictionary:
	if categoria == "" or not trivia.has(categoria):
		categoria = categorias().pick_random()
	var lista := preguntas_de(categoria)
	var candidatas := lista.filter(func(p): return not _recientes.has(p["pregunta"]))
	if candidatas.is_empty():
		candidatas = lista
	var elegida: Dictionary = candidatas.pick_random().duplicate(true)
	_recientes.append(elegida["pregunta"])
	if _recientes.size() > 15:
		_recientes.pop_front()
	elegida["correcta"] = int(elegida["correcta"])
	elegida["bonus"] = int(elegida.get("bonus", 1))
	elegida["categoria"] = categoria
	elegida["categoria_nombre"] = nombres_categoria.get(categoria, categoria)
	return elegida
