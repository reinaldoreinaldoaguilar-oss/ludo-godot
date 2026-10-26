class_name BoardManager
extends Node2D
## Controla el flujo de la partida (máquina de estados de turnos):
## inicio de turno -> tirar dado -> elegir ficha -> mover -> capturas/meta -> siguiente turno.
## Las reglas puras viven en LudoRules; aquí solo se orquesta.

@export var way_points: WayPointsManager
@export var piecesManager: PiecesManager
@export var animation_PlayerForPlaces: AnimationPlayer

const PLACE_ANIMATIONS := {
	GameManager.PlayerColor.Green: "GreenPlaceAnimation",
	GameManager.PlayerColor.Yellow: "YellowPlaceAnimation",
	GameManager.PlayerColor.Blue: "BluePlaceAnimation",
	GameManager.PlayerColor.Red: "RedPlaceAnimation",
}

## Pausa (en segundos) antes de que un bot actúe, para que se entienda la jugada.
var bot_delay: float = 0.8

var currentPlayerColor: GameManager.PlayerColor = GameManager.PlayerColor.Green
var currentDiceValue: int = -1
var sixes_in_a_row: int = 0
var lobby_attempts: int = 0 # Intentos para sacar 6 con todas las fichas en la base.
var active_colors: Array[int] = []
var finished_colors: Array[int] = [] # Orden de llegada = ranking.
var is_game_over: bool = false
var stats: Dictionary = {} # color -> {capturas, seises, trivia_ok, trivia_total, puntos}
var rng := RandomNumberGenerator.new()
var dice: Dice

signal turn_started(color: int, is_bot: bool)
signal dice_result(color: int, value: int)
signal waiting_for_piece(color: int, movable: Array)
signal game_message(text: String, color: int)
signal piece_captured(by_color: int, victim: Piece)
signal piece_reached_home(piece: Piece)
signal player_finished(color: int, place: int)
signal game_over(ranking: Array)
signal stats_changed(stats: Dictionary)

func _ready() -> void:
	add_to_group("Tablero")
	rng.randomize()
	bot_delay = GameManager.bot_delay()
	dice = get_tree().get_first_node_in_group("Dado")
	GameManager.OnPlayerSelectPiece.connect(_on_player_select_piece)
	for j in GameManager.jugadores:
		active_colors.append(j["color"])
		stats[j["color"]] = {"capturas": 0, "seises": 0, "trivia_ok": 0, "trivia_total": 0, "puntos": 0}
	start_game.call_deferred()

func start_game() -> void:
	currentPlayerColor = LudoRules.next_color(-1, active_colors, finished_colors)
	begin_turn()

# ---------------------------------------------------------------- Turnos

func begin_turn() -> void:
	if is_game_over:
		return
	currentDiceValue = -1
	PlayPlaceAnimation()
	var bot := GameManager.is_bot(currentPlayerColor)
	turn_started.emit(currentPlayerColor, bot)
	GameManager.UpdateGameCurrentState(GameManager.GameStateEnum.PlayerCanRollDice)
	if bot:
		await wait(bot_delay)
		dice.RollDice()
	else:
		dice.enabled = true

func end_turn(extra_turn: bool) -> void:
	if is_game_over:
		return
	piecesManager.set_all_selectable(false)
	if extra_turn and not finished_colors.has(currentPlayerColor):
		game_message.emit("¡Turno extra!", currentPlayerColor)
	else:
		sixes_in_a_row = 0
		lobby_attempts = 0
		currentPlayerColor = LudoRules.next_color(currentPlayerColor, active_colors, finished_colors)
	begin_turn()

func _on_dice_root_on_dice_roll_begin() -> void:
	animation_PlayerForPlaces.stop()
	GameManager.UpdateGameCurrentState(GameManager.GameStateEnum.Null)

func _on_dice_root_on_dice_rolled(value: int) -> void:
	currentDiceValue = value
	dice_result.emit(currentPlayerColor, value)
	var bot := GameManager.is_bot(currentPlayerColor)

	if value == 6:
		sixes_in_a_row += 1
		add_stat(currentPlayerColor, "seises", 1)
		if sixes_in_a_row >= LudoRules.MAX_SIXES_IN_A_ROW:
			game_message.emit("¡Tres seises seguidos! Pierdes el turno.", currentPlayerColor)
			await wait(1.0)
			end_turn(false)
			return
		# Trivia original: para conservar el 6 hay que acertar la pregunta.
		if not bot and not await ask_trivia():
			game_message.emit("Respuesta incorrecta: pierdes el 6.", currentPlayerColor)
			end_turn(false)
			return
	else:
		sixes_in_a_row = 0

	var snapshot := get_snapshot()
	var moves := LudoRules.valid_moves(snapshot["dicts"], currentPlayerColor, value)
	if moves.is_empty():
		# Con todas las fichas en la base hay hasta 3 intentos para sacar un 6.
		var group := piecesManager.GetPieceGroupBasedOnType(currentPlayerColor)
		var none_on_board := not group.Pieces.any(func(p: Piece): return p.CurrentState == GameManager.PieceStateEnum.InWayPoint)
		if none_on_board and lobby_attempts < LudoRules.LOBBY_ATTEMPTS - 1:
			lobby_attempts += 1
			game_message.emit("Necesitas un 6. Intento %d de %d." % [lobby_attempts + 1, LudoRules.LOBBY_ATTEMPTS], currentPlayerColor)
			await wait(0.6)
			begin_turn()
			return
		game_message.emit("Sin movimientos posibles.", currentPlayerColor)
		await wait(0.9)
		end_turn(value == 6)
		return

	var movable: Array[Piece] = []
	for m in moves:
		movable.append(snapshot["pieces"][m])

	if bot:
		var choice := LudoRules.choose_move(snapshot["dicts"], currentPlayerColor, value, GameManager.dificultad, rng)
		await wait(bot_delay * 0.6)
		execute_move(snapshot["pieces"][choice])
	else:
		for piece in movable:
			piece.set_selectable(true)
		waiting_for_piece.emit(currentPlayerColor, movable)
		GameManager.UpdateGameCurrentState(GameManager.GameStateEnum.PlayerSelectPiece)

func _on_player_select_piece(piece: Piece) -> void:
	if GameManager.GameCurrentState != GameManager.GameStateEnum.PlayerSelectPiece:
		return
	if piece.CurrentPlayerColor != currentPlayerColor:
		return
	if not LudoRules.can_move(piece.CurrentState, piece.CurrentPosition, currentDiceValue):
		game_message.emit("Esa ficha no puede moverse.", currentPlayerColor)
		return
	GameManager.UpdateGameCurrentState(GameManager.GameStateEnum.Null)
	piecesManager.set_all_selectable(false)
	execute_move(piece)

# ---------------------------------------------------------------- Movimiento

func execute_move(piece: Piece) -> void:
	var dice_value := currentDiceValue
	var extra_turn := dice_value == 6
	var color := piece.CurrentPlayerColor
	var from_lobby := piece.CurrentState == GameManager.PieceStateEnum.InLobby
	var start := piece.CurrentPosition
	var target := LudoRules.target_progress(piece.CurrentState, start, dice_value)
	var origin_wp := piece.CurrentWayPoint

	if origin_wp:
		origin_wp.remove_piece(piece)
	await piece.move_along(path_points(color, start, target, from_lobby))
	var target_wp := way_points.get_waypoint(target, color)

	# Trivia original: caer en una estrella obliga a responder; si fallas, regresas.
	if not from_lobby and target_wp.isThisSafePlace and target != LudoRules.MAX_PROGRESS \
			and not GameManager.is_bot(color) and not await ask_trivia():
		game_message.emit("Fallaste: la ficha regresa.", color)
		var back: Array[Vector2] = []
		for i in range(target - 1, start - 1, -1):
			back.append(way_points.GetPositionOfThisPoint(i, color))
		await piece.move_along(back)
		origin_wp.add_piece(piece)
		end_turn(extra_turn)
		return

	piece.CurrentPosition = target
	piece.CurrentState = GameManager.PieceStateEnum.InWayPoint

	# Capturas: las fichas rivales en la casilla vuelven a su base.
	var snapshot := get_snapshot()
	for idx in LudoRules.captures_at(snapshot["dicts"], color, target):
		var victim: Piece = snapshot["pieces"][idx]
		piece_captured.emit(color, victim)
		if victim.CurrentWayPoint:
			victim.CurrentWayPoint.remove_piece(victim)
		victim.send_to_lobby()
		add_stat(color, "capturas", 1)
		game_message.emit("¡%s capturó una ficha %s!" % [GameManager.get_nombre(color), GameManager.COLOR_NAMES[victim.CurrentPlayerColor]], color)
		extra_turn = true

	if target == LudoRules.MAX_PROGRESS:
		piece.CurrentState = GameManager.PieceStateEnum.InHouse
		piece.IsInHome = true
		piece_reached_home.emit(piece)
		extra_turn = true
		check_player_finished(color)

	target_wp.add_piece(piece)
	if is_game_over:
		return
	end_turn(extra_turn)

## Posiciones globales que recorre una ficha desde `from` (sin incluirla) hasta `to`.
func path_points(color: int, from: int, to: int, from_lobby: bool) -> Array[Vector2]:
	var points: Array[Vector2] = []
	if from_lobby:
		points.append(way_points.GetPositionOfThisPoint(0, color))
		return points
	for i in range(from + 1, to + 1):
		points.append(way_points.GetPositionOfThisPoint(i, color))
	return points

func check_player_finished(color: int) -> void:
	if not piecesManager.GetPieceGroupBasedOnType(color).HasThisPlayerCompleted():
		return
	finished_colors.append(color)
	player_finished.emit(color, finished_colors.size())
	game_message.emit("¡%s terminó en el puesto %d!" % [GameManager.get_nombre(color), finished_colors.size()], color)
	var remaining := active_colors.filter(func(c): return not finished_colors.has(c))
	if GameManager.modo_victoria == GameManager.VictoryMode.Rapida or remaining.size() <= 1:
		finish_game()

func finish_game() -> void:
	is_game_over = true
	dice.enabled = false
	piecesManager.set_all_selectable(false)
	# Los que no terminaron se ordenan por fichas en meta y progreso total.
	var remaining := active_colors.filter(func(c): return not finished_colors.has(c))
	remaining.sort_custom(func(a, b): return progress_score(a) > progress_score(b))
	var ranking: Array = finished_colors.duplicate()
	ranking.append_array(remaining)
	GameManager.UpdateGameCurrentState(GameManager.GameStateEnum.GameOver)
	GameManager.registrar_partida(ranking, stats)
	game_over.emit(ranking)

func progress_score(color: int) -> int:
	var total := 0
	for p in piecesManager.GetPieceGroupBasedOnType(color).Pieces:
		total += 100 if p.CurrentState == GameManager.PieceStateEnum.InHouse else p.CurrentPosition
	return total

# ---------------------------------------------------------------- Utilidades

## Fichas activas y su representación en diccionarios para LudoRules (mismo orden).
func get_snapshot() -> Dictionary:
	var pieces := piecesManager.get_active_pieces()
	var dicts: Array = []
	for p in pieces:
		dicts.append(p.to_dict())
	return {"pieces": pieces, "dicts": dicts}

func ask_trivia() -> bool:
	if not GameManager.trivia_activa:
		return true
	var ventana = get_tree().get_first_node_in_group("Trivia")
	if ventana == null:
		return true
	var result: Dictionary = await ventana.preguntar()
	add_stat(currentPlayerColor, "trivia_total", 1)
	if result["correcta"]:
		add_stat(currentPlayerColor, "trivia_ok", 1)
		add_stat(currentPlayerColor, "puntos", result["puntos"])
	return result["correcta"]

func add_stat(color: int, key: String, amount: int) -> void:
	if stats.has(color):
		stats[color][key] += amount
		stats_changed.emit(stats)

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds, false).timeout

func PlayPlaceAnimation() -> void:
	animation_PlayerForPlaces.stop()
	animation_PlayerForPlaces.play(PLACE_ANIMATIONS[currentPlayerColor])
