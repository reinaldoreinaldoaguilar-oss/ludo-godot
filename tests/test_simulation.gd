extends Node
## Simulación de partidas completas sin pantalla para comprobar que el juego
## nunca se congela y que siempre termina con un ranking válido. Ejecutar:
##   godot --headless res://tests/simulation.tscn
## Los jugadores "humanos" los controla este script (tira, elige ficha y responde trivia).

const LEVEL := "res://Levels/Level_MainGamePlay.tscn"
const TIME_LIMIT_MS := 240000

var scenarios := [
	{"nombre": "4 bots", "humanos": [], "colores": [0, 1, 2, 3], "modo": 1, "trivia": false},
	{"nombre": "1 humano + 3 bots con trivia", "humanos": [0], "colores": [0, 1, 2, 3], "modo": 1, "trivia": true},
	{"nombre": "2 humanos, partida rápida", "humanos": [0, 2], "colores": [0, 2], "modo": 0, "trivia": true},
	{"nombre": "3 jugadores mixtos", "humanos": [1], "colores": [0, 1, 2], "modo": 1, "trivia": true},
]
var current := -1
var board: BoardManager
var start_ms := 0
var failures := 0
var ranking: Array = []
var turns := 0
var rng := RandomNumberGenerator.new()
var gm: Node
var level: Node

func _ready() -> void:
	gm = GameManager
	gm.registrar_estadisticas = false
	gm.velocidad_bots = 1
	rng.seed = 42
	Engine.time_scale = 60.0
	next_scenario.call_deferred()

func next_scenario() -> void:
	current += 1
	if current >= scenarios.size():
		print("== Simulación terminada: %d fallos ==" % failures)
		get_tree().quit(1 if failures > 0 else 0)
		return
	var sc: Dictionary = scenarios[current]
	var lista: Array[Dictionary] = []
	for c in sc["colores"]:
		lista.append({"color": c, "nombre": "J" + str(c), "es_bot": not sc["humanos"].has(c)})
	gm.configurar_partida(lista, current % 3, sc["modo"], sc["trivia"])
	board = null
	ranking = []
	turns = 0
	start_ms = Time.get_ticks_msec()
	if level:
		level.queue_free()
		await get_tree().process_frame
	level = load(LEVEL).instantiate()
	add_child(level)

func _process(_delta: float) -> void:
	if current >= scenarios.size():
		return
	if board == null:
		board = get_tree().get_first_node_in_group("Tablero")
		if board:
			board.game_over.connect(func(r): ranking = r)
			board.turn_started.connect(func(_c, _b): turns += 1)
		return
	if not ranking.is_empty():
		verify()
		next_scenario()
		return
	if Time.get_ticks_msec() - start_ms > TIME_LIMIT_MS:
		fail("tiempo agotado: el juego se congeló (turnos jugados: %d, estado: %d)" % [turns, gm.GameCurrentState])
		next_scenario()
		return
	drive_humans()
	return

## Juega por los humanos.
func drive_humans() -> void:
	var trivia = get_tree().get_first_node_in_group("Trivia")
	if trivia and trivia.visible:
		trivia.evaluar_respuesta(trivia.indice_correcto if rng.randf() < 0.6 else (trivia.indice_correcto + 1) % 4)
		return
	if gm.is_bot(board.currentPlayerColor):
		return
	var dice: Dice = board.dice
	if gm.GameCurrentState == 1 and dice.enabled and not dice.rolling:
		dice.RollDice()
	elif gm.GameCurrentState == 2:
		var options := board.piecesManager.get_active_pieces().filter(func(p): return p.selectable)
		if options.is_empty():
			fail("se pidió elegir ficha pero ninguna es seleccionable")
		else:
			options.pick_random().select()

func verify() -> void:
	var sc: Dictionary = scenarios[current]
	var name: String = sc["nombre"]
	var ok := true
	if ranking.size() != sc["colores"].size():
		fail("%s: el ranking no incluye a todos" % name); ok = false
	var winner: int = ranking[0]
	if not board.piecesManager.GetPieceGroupBasedOnType(winner).HasThisPlayerCompleted():
		fail("%s: el ganador no tiene sus 4 fichas en meta" % name); ok = false
	for p in board.piecesManager.get_active_pieces():
		if p.CurrentState == 1 and (p.CurrentPosition < 0 or p.CurrentPosition > 55):
			fail("%s: ficha con posición inválida %d" % [name, p.CurrentPosition]); ok = false
	var capturas := 0
	for c in board.stats:
		capturas += board.stats[c]["capturas"]
	if ok:
		print("  OK   %s — %d turnos, %d capturas, ganador: %s" % [name, turns, capturas, gm.COLOR_NAMES[winner]])

func fail(msg: String) -> void:
	failures += 1
	print("  FAIL ", msg)
