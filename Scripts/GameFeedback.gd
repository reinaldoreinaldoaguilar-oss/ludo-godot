extends Node2D
## "Jugo" visual y sonoro: escucha las señales del tablero y reacciona con
## sonidos, partículas y temblor de cámara. No modifica el estado del juego.

@export var camera: Camera2D

var board: BoardManager
var _shake: float = 0.0

func _ready() -> void:
	board = get_tree().get_first_node_in_group("Tablero")
	board.turn_started.connect(_on_turn_started)
	board.piece_captured.connect(_on_piece_captured)
	board.piece_reached_home.connect(_on_piece_home)
	board.game_message.connect(_on_message)
	board.game_over.connect(func(_r): AudioManager.play("win"))
	AudioManager.play_music()

func _on_turn_started(color: int, _is_bot: bool) -> void:
	board.dice.glow_color = GameManager.COLOR_VALUES[color]
	AudioManager.play("turn")

func _on_piece_captured(by_color: int, victim: Piece) -> void:
	AudioManager.play("capture")
	Effects.burst(self, victim.global_position, GameManager.COLOR_VALUES[victim.CurrentPlayerColor], 50)
	Effects.burst(self, victim.global_position, GameManager.COLOR_VALUES[by_color], 25, 500)
	_shake = 40.0

func _on_piece_home(piece: Piece) -> void:
	AudioManager.play("home")
	Effects.burst(self, piece.global_position, Color("ffd32a"), 60, 900)

func _on_message(text: String, _color: int) -> void:
	if text.begins_with("¡Turno extra"):
		AudioManager.play("extra")

func _process(delta: float) -> void:
	if camera == null:
		return
	if _shake > 0.1:
		camera.offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * _shake
		_shake = lerpf(_shake, 0.0, delta * 8.0)
	else:
		camera.offset = Vector2.ZERO
