class_name PlayerPiecesGroup
extends Node2D
## Las 4 fichas de un color.

@export var Pieces: Array[Piece]
@export var PlayerFirstPosition: int
@export var CurrentPlayerColor: GameManager.PlayerColor
@export var IsAutoPieceSelect: bool # Se calcula desde GameManager (bot o humano).

func _ready() -> void:
	IsAutoPieceSelect = GameManager.is_bot(CurrentPlayerColor)
	visible = GameManager.is_color_activo(CurrentPlayerColor)
	for piece in Pieces:
		piece.CurrentState = GameManager.PieceStateEnum.InLobby

func HasThisPlayerCompleted() -> bool:
	return Pieces.all(func(p: Piece): return p.CurrentState == GameManager.PieceStateEnum.InHouse)

func HasUnlockedAnyPiece() -> bool:
	return Pieces.any(func(p: Piece): return p.CurrentState != GameManager.PieceStateEnum.InLobby)

func pieces_home() -> int:
	return Pieces.filter(func(p: Piece): return p.CurrentState == GameManager.PieceStateEnum.InHouse).size()
