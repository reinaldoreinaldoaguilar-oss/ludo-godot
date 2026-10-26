class_name WayPointsManager
extends Node2D
## Da acceso a los caminos de cada color (57 casillas: 51 compartidas + 5 de pasillo + meta).

@export var main_path: Node2D
@export var green_path: Array[WayPoint]
@export var yellow_path: Array[WayPoint]
@export var blue_path: Array[WayPoint]
@export var red_path: Array[WayPoint]

func get_path_for(color: GameManager.PlayerColor) -> Array[WayPoint]:
	match color:
		GameManager.PlayerColor.Green: return green_path
		GameManager.PlayerColor.Yellow: return yellow_path
		GameManager.PlayerColor.Blue: return blue_path
		_: return red_path

func get_waypoint(index: int, color: GameManager.PlayerColor) -> WayPoint:
	var path := get_path_for(color)
	if index < 0 or index >= path.size():
		push_error("Índice de casilla fuera de rango: %d" % index)
		return null
	return path[index]

func GetPositionOfThisPoint(index: int, color: GameManager.PlayerColor) -> Vector2:
	var wp := get_waypoint(index, color)
	return wp.global_position if wp else Vector2.ZERO

func GetCount(color: GameManager.PlayerColor) -> int:
	return get_path_for(color).size()
