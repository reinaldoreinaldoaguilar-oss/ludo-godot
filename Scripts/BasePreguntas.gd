extends Node
## Autoload: banco de preguntas de la trivia, cargado desde Data/preguntas.json.
## Para agregar preguntas basta con editar ese archivo, sin tocar código.

const RUTA_PREGUNTAS := "res://Data/preguntas.json"

## categoria_id -> Array de preguntas {pregunta, opciones[4], correcta, bonus}
var trivia: Dictionary = {}
var nombres_categoria: Dictionary = {}
var _recientes: Array[String] = [] # Evita repetir la misma pregunta seguido.

func _init() -> void:
	cargar(RUTA_PREGUNTAS)

func cargar(ruta: String) -> void:
	var texto := FileAccess.get_file_as_string(ruta)
	var datos = JSON.parse_string(texto)
	if typeof(datos) != TYPE_DICTIONARY or not datos.has("categorias"):
		push_error("No se pudo leer el banco de preguntas: " + ruta)
		return
	trivia.clear()
	for cat in datos["categorias"]:
		var validas: Array = cat["preguntas"].filter(es_valida)
		trivia[cat["id"]] = validas
		nombres_categoria[cat["id"]] = cat["nombre"]

func es_valida(p) -> bool:
	return typeof(p) == TYPE_DICTIONARY and p.has("pregunta") and p.get("opciones", []).size() == 4 \
		and int(p.get("correcta", -1)) >= 0 and int(p.get("correcta", -1)) < 4

func categorias() -> Array:
	return trivia.keys()

func total_preguntas() -> int:
	var total := 0
	for lista in trivia.values():
		total += lista.size()
	return total

## Devuelve una pregunta al azar (de la categoría indicada o de cualquiera).
func pregunta_aleatoria(categoria: String = "") -> Dictionary:
	if categoria == "" or not trivia.has(categoria):
		categoria = categorias().pick_random()
	var lista: Array = trivia[categoria]
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
