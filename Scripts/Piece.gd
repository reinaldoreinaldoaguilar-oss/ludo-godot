class_name Piece
extends Node2D
## Una ficha del tablero. Sabe dibujarse, moverse con animación y avisar cuando
## el jugador la toca. Las reglas las decide BoardManager con LudoRules.

const STEP_TIME := 0.16
const HOP_HEIGHT := 45.0
const RING_RADIUS := 78.0

@export var CurrentPlayerColor: GameManager.PlayerColor
@export var PieceSprite: Sprite2D
@export var animation_PieceSelect: AnimationPlayer

var CurrentPosition: int = 0 # Progreso en su camino (ver LudoRules).
var CurrentState: GameManager.PieceStateEnum = GameManager.PieceStateEnum.InLobby
var CurrentWayPoint: WayPoint
var IsInHome: bool = false
var lobby_position: Vector2
var selectable: bool = false
var hovered: bool = false
var _time: float = 0.0
var _base_z: int = 0

func _ready() -> void:
	lobby_position = global_position
	_base_z = z_index
	set_process(false)

func to_dict() -> Dictionary:
	return {"color": CurrentPlayerColor, "state": CurrentState, "progress": CurrentPosition}

func _reset_state() -> void:
	CurrentPosition = 0
	CurrentState = GameManager.PieceStateEnum.InLobby
	IsInHome = false
	CurrentWayPoint = null

## Vuelve a la base al instante (usado al reiniciar).
func reset_to_lobby() -> void:
	_reset_state()
	global_position = lobby_position

## Vuelve a la base con animación (al ser capturada).
func send_to_lobby() -> void:
	_reset_state()
	z_index = _base_z + 20
	var tw := create_tween().set_parallel()
	tw.tween_property(self, "global_position", lobby_position, 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(PieceSprite, "rotation", TAU * 2, 0.55)
	await tw.finished
	PieceSprite.rotation = 0
	z_index = _base_z
	_squash()

func _input(event: InputEvent) -> void:
	if not selectable or GameManager.GameCurrentState != GameManager.GameStateEnum.PlayerSelectPiece:
		return
	if event is InputEventMouseMotion:
		var over := _is_mouse_over()
		if over != hovered:
			hovered = over
			Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND if over else Input.CURSOR_ARROW)
	elif event.is_action_pressed("PlayerClick") and _is_mouse_over():
		get_viewport().set_input_as_handled()
		select()

func _is_mouse_over() -> bool:
	return PieceSprite.is_pixel_opaque(PieceSprite.get_local_mouse_position())

## La llaman el clic del jugador y la IA de los bots.
func select() -> void:
	AudioManager.play("select")
	GameManager.OnPlayerSelectPiece.emit(self)

## Recorre una lista de posiciones globales saltando casilla por casilla.
func move_along(points: Array[Vector2]) -> void:
	z_index = _base_z + 10
	for target in points:
		var start := global_position
		var tw := create_tween()
		tw.tween_method(func(t: float):
			global_position = start.lerp(target, t) + Vector2(0, -sin(t * PI) * HOP_HEIGHT),
			0.0, 1.0, STEP_TIME).set_trans(Tween.TRANS_SINE)
		await tw.finished
		AudioManager.play("step", 0.08)
	z_index = _base_z
	_squash()

func _squash() -> void:
	var tw := create_tween()
	tw.tween_property(PieceSprite, "scale", Vector2(1.15, 0.85), 0.07)
	tw.tween_property(PieceSprite, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func set_selectable(value: bool) -> void:
	selectable = value
	animation_PieceSelect.stop()
	PieceSprite.scale = Vector2.ONE
	if not value and hovered:
		hovered = false
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	_time = 0.0
	set_process(value)
	z_index = _base_z + (5 if value else 0)
	queue_redraw()

func _process(delta: float) -> void:
	_time += delta
	var pulse := 1.0 + sin(_time * 6.0) * 0.06 + (0.08 if hovered else 0.0)
	PieceSprite.scale = Vector2(pulse, pulse)
	queue_redraw()

## Anillo brillante bajo las fichas que se pueden mover.
func _draw() -> void:
	if not selectable:
		return
	var color: Color = GameManager.COLOR_VALUES[CurrentPlayerColor].lightened(0.3)
	var r := RING_RADIUS + sin(_time * 6.0) * 6.0
	color.a = 0.35
	draw_circle(Vector2(0, 40), r, color)
	color.a = 0.95
	draw_arc(Vector2(0, 40), r, 0, TAU, 48, color, 8.0, true)

## Compatibilidad con el código original.
func PlayAnimation() -> void:
	set_selectable(true)

func StopAnimation() -> void:
	set_selectable(false)

func GetCurrentPosition() -> int:
	return CurrentPosition
