class_name Piece
extends Node2D
## Una ficha del tablero. Sabe dibujarse, moverse y avisar cuando el jugador la toca.
## Las reglas (si se puede mover, capturas...) las decide BoardManager con LudoRules.

const STEP_TIME := 0.18

@export var CurrentPlayerColor: GameManager.PlayerColor
@export var PieceSprite: Sprite2D
@export var animation_PieceSelect: AnimationPlayer

var CurrentPosition: int = 0 # Progreso en su camino (ver LudoRules).
var CurrentState: GameManager.PieceStateEnum = GameManager.PieceStateEnum.InLobby
var CurrentWayPoint: WayPoint
var IsInHome: bool = false
var lobby_position: Vector2
var selectable: bool = false

func _ready() -> void:
	lobby_position = global_position

func to_dict() -> Dictionary:
	return {"color": CurrentPlayerColor, "state": CurrentState, "progress": CurrentPosition}

func reset_to_lobby() -> void:
	CurrentPosition = 0
	CurrentState = GameManager.PieceStateEnum.InLobby
	IsInHome = false
	CurrentWayPoint = null
	global_position = lobby_position

func _input(event: InputEvent) -> void:
	if not selectable or GameManager.GameCurrentState != GameManager.GameStateEnum.PlayerSelectPiece:
		return
	if event.is_action_pressed("PlayerClick") and PieceSprite.is_pixel_opaque(PieceSprite.get_local_mouse_position()):
		get_viewport().set_input_as_handled()
		select()

## La llaman el clic del jugador y la IA de los bots.
func select() -> void:
	GameManager.OnPlayerSelectPiece.emit(self)

## Recorre una lista de posiciones globales, una casilla a la vez.
func move_along(points: Array[Vector2]) -> void:
	for p in points:
		global_position = p
		await get_tree().create_timer(STEP_TIME, false).timeout

func set_selectable(value: bool) -> void:
	selectable = value
	if value:
		animation_PieceSelect.play("PieceAnimation_Select")
	else:
		animation_PieceSelect.play("RESET")
		animation_PieceSelect.stop()

## Compatibilidad con el código original.
func PlayAnimation() -> void:
	set_selectable(true)

func StopAnimation() -> void:
	set_selectable(false)

func GetCurrentPosition() -> int:
	return CurrentPosition
