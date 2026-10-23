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

signal OnGameCurrentStateChange(updatedGameState: GameStateEnum)
signal OnPlayerSelectPiece(value: Piece) # La usa BoardManager, no eliminar.

func _ready() -> void:
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
