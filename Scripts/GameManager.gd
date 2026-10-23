extends Node
## Autoload global: estados del juego, configuración de la partida y señales compartidas.

enum GameStateEnum { Null, PlayerCanRollDice, PlayerSelectPiece, GameOver }
enum PieceStateEnum { InLobby, InWayPoint, InHouse }
enum PlayerColor { Green, Yellow, Blue, Red }
enum Difficulty { Facil, Normal, Dificil }
enum VictoryMode { Rapida, Completa }

## Orden de turnos (sentido del tablero).
const TURN_ORDER: Array[int] = [PlayerColor.Green, PlayerColor.Yellow, PlayerColor.Blue, PlayerColor.Red]

const COLOR_NAMES := {
	PlayerColor.Green: "Verde",
	PlayerColor.Yellow: "Amarillo",
	PlayerColor.Blue: "Azul",
	PlayerColor.Red: "Rojo",
}

const COLOR_VALUES := {
	PlayerColor.Green: Color("2ecc71"),
	PlayerColor.Yellow: Color("f1c40f"),
	PlayerColor.Blue: Color("3498db"),
	PlayerColor.Red: Color("e74c3c"),
}

var GameCurrentState: GameStateEnum = GameStateEnum.PlayerCanRollDice

## Compatibilidad con el código original: true = el jugador verde es humano y el resto bots.
var modo_contra_bots: bool = false

## Configuración de la partida actual. Cada jugador: {color, nombre, es_bot}.
var jugadores: Array[Dictionary] = []
var dificultad: Difficulty = Difficulty.Normal
var modo_victoria: VictoryMode = VictoryMode.Completa
var trivia_activa: bool = true

const SETTINGS_PATH := "user://ajustes.cfg"
const STATS_PATH := "user://estadisticas.cfg"
const BOT_DELAYS := [1.3, 0.8, 0.35] # Lenta, Normal, Rápida

## Ajustes guardados entre sesiones.
var velocidad_bots: int = 1
## Los tests lo desactivan para no ensuciar el historial real.
var registrar_estadisticas: bool = true

## Estadísticas históricas (se guardan en user://estadisticas.cfg).
var historial := {"partidas": 0, "victorias_humanas": 0, "trivia_ok": 0, "trivia_total": 0, "capturas": 0}

signal OnGameCurrentStateChange(updatedGameState: GameStateEnum)
signal OnPlayerSelectPiece(value: Piece) # La usa BoardManager, no eliminar.

func _ready() -> void:
	cargar_ajustes()
	cargar_historial()
	if jugadores.is_empty():
		configurar_partida_rapida(false)

func UpdateGameCurrentState(updateGameCurrentState: GameStateEnum) -> void:
	GameCurrentState = updateGameCurrentState
	OnGameCurrentStateChange.emit(GameCurrentState)

## Configura 4 jugadores: todos humanos, o verde humano y el resto bots.
func configurar_partida_rapida(contra_bots: bool) -> void:
	modo_contra_bots = contra_bots
	jugadores.clear()
	for color in TURN_ORDER:
		var bot := contra_bots and color != PlayerColor.Green
		jugadores.append({
			"color": color,
			"nombre": ("Bot " + COLOR_NAMES[color]) if bot else ("Jugador " + COLOR_NAMES[color]),
			"es_bot": bot,
		})

func configurar_partida(lista_jugadores: Array[Dictionary], nueva_dificultad: Difficulty, nuevo_modo: VictoryMode, con_trivia: bool) -> void:
	jugadores = lista_jugadores
	dificultad = nueva_dificultad
	modo_victoria = nuevo_modo
	trivia_activa = con_trivia
	modo_contra_bots = jugadores.any(func(j): return j["es_bot"])

func get_jugador(color: PlayerColor) -> Dictionary:
	for j in jugadores:
		if j["color"] == color:
			return j
	return {}

func is_color_activo(color: PlayerColor) -> bool:
	return not get_jugador(color).is_empty()

func is_bot(color: PlayerColor) -> bool:
	var j := get_jugador(color)
	return not j.is_empty() and j["es_bot"]

func get_nombre(color: PlayerColor) -> String:
	var j := get_jugador(color)
	return j.get("nombre", COLOR_NAMES[color])

# ---------------------------------------------------------------- Persistencia

func bot_delay() -> float:
	return BOT_DELAYS[clampi(velocidad_bots, 0, BOT_DELAYS.size() - 1)]

func set_ajuste(clave: String, valor) -> void:
	set(clave, valor)
	var cfg := ConfigFile.new()
	cfg.load(SETTINGS_PATH)
	cfg.set_value("juego", clave, valor)
	cfg.save(SETTINGS_PATH)

func cargar_ajustes() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS_PATH) == OK:
		velocidad_bots = cfg.get_value("juego", "velocidad_bots", velocidad_bots)

## Guarda la última configuración de partida para proponerla la próxima vez.
func guardar_ultima_partida() -> void:
	var cfg := ConfigFile.new()
	cfg.load(SETTINGS_PATH)
	cfg.set_value("ultima_partida", "jugadores", jugadores)
	cfg.set_value("ultima_partida", "dificultad", dificultad)
	cfg.set_value("ultima_partida", "modo_victoria", modo_victoria)
	cfg.set_value("ultima_partida", "trivia", trivia_activa)
	cfg.save(SETTINGS_PATH)

func cargar_ultima_partida() -> Dictionary:
	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS_PATH) != OK or not cfg.has_section("ultima_partida"):
		return {}
	return {
		"jugadores": cfg.get_value("ultima_partida", "jugadores", []),
		"dificultad": cfg.get_value("ultima_partida", "dificultad", Difficulty.Normal),
		"modo_victoria": cfg.get_value("ultima_partida", "modo_victoria", VictoryMode.Completa),
		"trivia": cfg.get_value("ultima_partida", "trivia", true),
	}

func cargar_historial() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(STATS_PATH) == OK:
		for k in historial:
			historial[k] = cfg.get_value("historial", k, 0)

## Suma los resultados de una partida terminada al historial.
func registrar_partida(ranking: Array, stats: Dictionary) -> void:
	if not registrar_estadisticas:
		return
	historial["partidas"] += 1
	if not ranking.is_empty() and not is_bot(ranking[0]):
		historial["victorias_humanas"] += 1
	for color in stats:
		if not is_bot(color):
			historial["trivia_ok"] += stats[color]["trivia_ok"]
			historial["trivia_total"] += stats[color]["trivia_total"]
			historial["capturas"] += stats[color]["capturas"]
	var cfg := ConfigFile.new()
	for k in historial:
		cfg.set_value("historial", k, historial[k])
	cfg.save(STATS_PATH)
