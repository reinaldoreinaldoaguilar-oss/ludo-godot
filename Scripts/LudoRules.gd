class_name LudoRules
extends RefCounted
## Reglas puras del Ludo (sin nodos ni escenas). Así se pueden probar con tests
## automáticos y las usan tanto el tablero como la IA de los bots.
##
## Cada ficha se representa con un diccionario: {"color", "state", "progress"}.
## "progress" es el índice dentro del camino de su color: 0 = casilla de salida,
## 50 = última casilla compartida, 51..55 = pasillo de su color, 56 = meta.

const MAX_PROGRESS := 56
const LAST_SHARED := 50
const TRACK_LENGTH := 52
const START_OFFSET := {
	GameManager.PlayerColor.Green: 0,
	GameManager.PlayerColor.Yellow: 13,
	GameManager.PlayerColor.Blue: 26,
	GameManager.PlayerColor.Red: 39,
}
## Casillas seguras (estrellas y salidas) del recorrido compartido.
const SAFE_CELLS: Array[int] = [0, 8, 13, 21, 26, 34, 39, 47]
const MAX_SIXES_IN_A_ROW := 3

static func can_move(state: int, progress: int, dice: int) -> bool:
	match state:
		GameManager.PieceStateEnum.InHouse:
			return false
		GameManager.PieceStateEnum.InLobby:
			return dice == 6
		_:
			# Para entrar a la meta hace falta el número exacto.
			return progress + dice <= MAX_PROGRESS

static func target_progress(state: int, progress: int, dice: int) -> int:
	if state == GameManager.PieceStateEnum.InLobby:
		return 0
	return progress + dice

## Casilla del recorrido compartido (0..51) o -1 si está en el pasillo/meta.
static func main_cell(color: int, progress: int) -> int:
	if progress < 0 or progress > LAST_SHARED:
		return -1
	return (START_OFFSET[color] + progress) % TRACK_LENGTH

static func is_safe(color: int, progress: int) -> bool:
	if progress > LAST_SHARED:
		return true
	return main_cell(color, progress) in SAFE_CELLS

static func is_on_board(piece: Dictionary) -> bool:
	return piece["state"] == GameManager.PieceStateEnum.InWayPoint

## Índices de las fichas de `color` que pueden moverse con `dice`.
static func valid_moves(pieces: Array, color: int, dice: int) -> Array[int]:
	var result: Array[int] = []
	for i in pieces.size():
		var p: Dictionary = pieces[i]
		if p["color"] == color and can_move(p["state"], p["progress"], dice):
			result.append(i)
	return result

## Índices de las fichas rivales que serían capturadas si `color` cae en `progress`.
static func captures_at(pieces: Array, color: int, progress: int) -> Array[int]:
	var result: Array[int] = []
	if is_safe(color, progress):
		return result
	var cell := main_cell(color, progress)
	for i in pieces.size():
		var p: Dictionary = pieces[i]
		if p["color"] != color and is_on_board(p) and main_cell(p["color"], p["progress"]) == cell:
			result.append(i)
	return result

## Cuántas fichas rivales podrían alcanzar la casilla en su próximo tiro.
static func threats_at(pieces: Array, color: int, progress: int) -> int:
	if is_safe(color, progress):
		return 0
	var cell := main_cell(color, progress)
	var count := 0
	for p in pieces:
		if p["color"] == color or not is_on_board(p) or p["progress"] > LAST_SHARED:
			continue
		var distance := (cell - main_cell(p["color"], p["progress"]) + TRACK_LENGTH) % TRACK_LENGTH
		if distance >= 1 and distance <= 6 and p["progress"] + distance <= LAST_SHARED:
			count += 1
	return count

## Puntuación de un movimiento (mayor = mejor). La usan los bots Normal y Difícil.
static func score_move(pieces: Array, index: int, dice: int, consider_danger: bool) -> float:
	var p: Dictionary = pieces[index]
	var target := target_progress(p["state"], p["progress"], dice)
	var score := float(dice)
	var captured := captures_at(pieces, p["color"], target)
	for c in captured:
		score += 100.0 + pieces[c]["progress"]
	if target == MAX_PROGRESS:
		score += 90.0
	if p["state"] == GameManager.PieceStateEnum.InLobby:
		score += 60.0
	elif target > LAST_SHARED and p["progress"] <= LAST_SHARED:
		score += 40.0
	if is_safe(p["color"], target):
		score += 20.0
	score += p["progress"] * 0.2
	if consider_danger:
		score -= 45.0 * threats_at(pieces, p["color"], target)
		if is_on_board(p):
			score += 30.0 * threats_at(pieces, p["color"], p["progress"])
	return score

## Elige qué ficha mover. Devuelve el índice en `pieces` o -1 si no hay movimiento.
static func choose_move(pieces: Array, color: int, dice: int, difficulty: int, rng: RandomNumberGenerator) -> int:
	var moves := valid_moves(pieces, color, dice)
	if moves.is_empty():
		return -1
	if difficulty == GameManager.Difficulty.Facil:
		return moves[rng.randi_range(0, moves.size() - 1)]
	var consider_danger := difficulty == GameManager.Difficulty.Dificil
	var best := moves[0]
	var best_score := -INF
	for m in moves:
		var s := score_move(pieces, m, dice, consider_danger)
		if difficulty == GameManager.Difficulty.Normal:
			s += rng.randf_range(0.0, 15.0) # Un poco de imprevisibilidad.
		if s > best_score:
			best_score = s
			best = m
	return best

## Siguiente color en jugar, saltando los inactivos y los que ya terminaron.
static func next_color(current: int, active: Array, finished: Array) -> int:
	var order := GameManager.TURN_ORDER
	var idx := order.find(current)
	for step in range(1, order.size() + 1):
		var c: int = order[(idx + step) % order.size()]
		if c in active and not c in finished:
			return c
	return -1
