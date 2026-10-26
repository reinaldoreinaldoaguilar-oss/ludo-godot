class_name PiecesManager
extends Node2D
## Acceso a todas las fichas del tablero.

@export var BluePieces: PlayerPiecesGroup
@export var YellowPieces: PlayerPiecesGroup
@export var GreenPieces: PlayerPiecesGroup
@export var RedPieces: PlayerPiecesGroup

func GetPieceGroupBasedOnType(color: GameManager.PlayerColor) -> PlayerPiecesGroup:
	match color:
		GameManager.PlayerColor.Green: return GreenPieces
		GameManager.PlayerColor.Yellow: return YellowPieces
		GameManager.PlayerColor.Blue: return BluePieces
		_: return RedPieces

## Fichas de los jugadores que participan en la partida.
func get_active_pieces() -> Array[Piece]:
	var result: Array[Piece] = []
	for color in GameManager.TURN_ORDER:
		if GameManager.is_color_activo(color):
			result.append_array(GetPieceGroupBasedOnType(color).Pieces)
	return result

func set_all_selectable(value: bool) -> void:
	for piece in get_active_pieces():
		piece.set_selectable(value)
