extends SceneTree
## Pruebas automáticas de las reglas. Ejecutar:
##   godot --headless --script res://tests/test_rules.gd

const G := GameManager.PlayerColor.Green
const Y := GameManager.PlayerColor.Yellow
const B := GameManager.PlayerColor.Blue
const R := GameManager.PlayerColor.Red
const LOBBY := GameManager.PieceStateEnum.InLobby
const BOARD := GameManager.PieceStateEnum.InWayPoint
const HOME := GameManager.PieceStateEnum.InHouse

var failures := 0
var total := 0

func check(condition: bool, name: String) -> void:
	total += 1
	if condition:
		print("  OK   ", name)
	else:
		failures += 1
		print("  FAIL ", name)

func piece(color: int, state: int, progress: int) -> Dictionary:
	return {"color": color, "state": state, "progress": progress}

func _initialize() -> void:
	print("== Pruebas de LudoRules ==")
	# Salir de la base
	check(LudoRules.can_move(LOBBY, 0, 6), "con 6 se sale de la base")
	for d in range(1, 6):
		check(not LudoRules.can_move(LOBBY, 0, d), "con %d no se sale de la base" % d)
	check(LudoRules.target_progress(LOBBY, 0, 6) == 0, "al salir va a la casilla de inicio")
	# Llegada exacta a la meta
	check(LudoRules.can_move(BOARD, 50, 6), "de 50 con 6 entra al pasillo")
	check(LudoRules.can_move(BOARD, 53, 3), "de 53 con 3 llega exacto a la meta")
	check(not LudoRules.can_move(BOARD, 53, 4), "de 53 con 4 se pasa: no puede mover")
	check(not LudoRules.can_move(HOME, 56, 1), "una ficha en meta no se mueve")
	# Casillas del recorrido compartido
	check(LudoRules.main_cell(G, 0) == 0, "verde sale en la casilla 0")
	check(LudoRules.main_cell(Y, 0) == 13, "amarillo sale en la casilla 13")
	check(LudoRules.main_cell(R, 50) == 37, "rojo termina el recorrido en la 37")
	check(LudoRules.main_cell(B, 51) == -1, "el pasillo no es casilla compartida")
	check(LudoRules.is_safe(G, 8), "la estrella 8 es segura")
	check(not LudoRules.is_safe(G, 5), "la casilla 5 no es segura")
	# Capturas
	var pieces := [piece(G, BOARD, 10), piece(Y, BOARD, 49)] # amarillo 49 -> celda (13+49)%52 = 10
	check(LudoRules.captures_at(pieces, G, 10) == [1], "verde captura al amarillo en la misma casilla")
	pieces = [piece(G, BOARD, 8), piece(Y, BOARD, 47)] # celda 8, estrella
	check(LudoRules.captures_at(pieces, G, 8).is_empty(), "no hay captura en casilla segura")
	pieces = [piece(G, BOARD, 10), piece(G, BOARD, 10)]
	check(LudoRules.captures_at(pieces, G, 10).is_empty(), "no se capturan fichas propias")
	pieces = [piece(G, BOARD, 10), piece(Y, LOBBY, 0)]
	check(LudoRules.captures_at(pieces, G, 10).is_empty(), "no se capturan fichas en la base")
	# Amenazas
	pieces = [piece(G, BOARD, 10), piece(R, BOARD, 20)] # rojo 20 -> celda 7, a 3 de la 10
	check(LudoRules.threats_at(pieces, G, 10) == 1, "detecta amenaza a 3 casillas")
	check(LudoRules.threats_at(pieces, G, 30) == 0, "sin amenaza lejos")
	# Movimientos válidos
	pieces = [piece(G, LOBBY, 0), piece(G, BOARD, 5), piece(G, HOME, 56), piece(Y, BOARD, 3)]
	check(LudoRules.valid_moves(pieces, G, 3) == [1], "con 3 solo se mueve la ficha en juego")
	check(LudoRules.valid_moves(pieces, G, 6) == [0, 1], "con 6 se mueve la de la base o la del tablero")
	# IA
	var rng := RandomNumberGenerator.new()
	rng.seed = 1
	pieces = [piece(G, BOARD, 4), piece(G, BOARD, 30), piece(Y, BOARD, 46)] # amarillo en celda 7
	for level in [GameManager.Difficulty.Normal, GameManager.Difficulty.Dificil]:
		check(LudoRules.choose_move(pieces, G, 3, level, rng) == 0, "IA nivel %d prefiere capturar" % level)
	pieces = [piece(G, LOBBY, 0), piece(G, LOBBY, 0)]
	check(LudoRules.choose_move(pieces, G, 2, GameManager.Difficulty.Facil, rng) == -1, "IA sin movimientos devuelve -1")
	for i in 50:
		var m := LudoRules.choose_move([piece(G, LOBBY, 0), piece(G, BOARD, 54)], G, 4, GameManager.Difficulty.Facil, rng)
		if m != -1:
			check(false, "IA fácil eligió un movimiento inválido")
			break
	check(true, "IA fácil nunca elige movimientos inválidos")
	# Turnos
	var active := [G, Y, B, R]
	check(LudoRules.next_color(-1, active, []) == G, "empieza el verde")
	check(LudoRules.next_color(R, active, []) == G, "después del rojo va el verde")
	check(LudoRules.next_color(G, active, [Y]) == B, "se salta al que ya terminó")
	check(LudoRules.next_color(G, [G, B], []) == B, "2 jugadores: verde contra azul")
	# Banco de preguntas
	var banco = root.get_node("BasePreguntas")
	check(banco.total_preguntas() >= 30, "banco de preguntas cargado (%d)" % banco.total_preguntas())
	var q: Dictionary = banco.pregunta_aleatoria("cultura")
	check(q["opciones"].size() == 4 and q["correcta"] in [0, 1, 2, 3], "pregunta con 4 opciones válidas")

	print("== %d/%d pruebas correctas ==" % [total - failures, total])
	quit(1 if failures > 0 else 0)
