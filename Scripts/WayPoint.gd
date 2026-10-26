class_name WayPoint
extends Node2D
## Casilla del tablero. Guarda qué fichas están encima para poder
## acomodarlas visualmente cuando comparten casilla.

@export var isThisSafePlace: bool
@export var IsThisHomePlace: bool

var occupants: Array[Piece] = []

func add_piece(piece: Piece) -> void:
	if not occupants.has(piece):
		occupants.append(piece)
	piece.CurrentWayPoint = self
	arrange()

func remove_piece(piece: Piece) -> void:
	occupants.erase(piece)
	if piece.CurrentWayPoint == self:
		piece.CurrentWayPoint = null
	arrange()

## Reparte las fichas alrededor del centro si hay más de una.
func arrange() -> void:
	var count := occupants.size()
	for i in count:
		var offset := Vector2.ZERO
		if count > 1:
			offset = Vector2(30, 0).rotated(TAU * i / count)
		occupants[i].global_position = global_position + offset
