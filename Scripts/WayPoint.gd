class_name WayPoint
extends Node2D

@export var isThisSafePlace:bool
@export var IsThisHomePlace:bool

var myHoldings: Array

#var wayPointManager:WayPointsManager
var boardManager:BoardManager

func _ready() -> void:
	#wayPointManager = get_tree().get_first_node_in_group("WayPointManagerGroup")
	boardManager = get_tree().get_first_node_in_group("BoardManager")
	pass

func SetPiece(piece)->void:
	
	myHoldings.push_back(piece)
	
	var hasKill:bool = HasWeHaveOpponentPiece()
	
	boardManager.DetectKill(null)
	if(hasKill):
		print("piece data __ ",piece.name)
		boardManager.DetectKill(myHoldings.pop_front())
		pass
	else:
		print("same as turn player")
		pass
		
	if IsThisHomePlace:
		piece.IsInHome = true
		pass
	pass

func ClearMe()->void:
	myHoldings.clear()
	pass
	
func HasWeHaveOpponentPiece()->bool: 
	print("waypoint piece count ",self.name,"__",myHoldings.size())
	if(isThisSafePlace): return false
	if(myHoldings.is_empty()): return false
	if(myHoldings.size()==1): return false
	
	var lastValue = myHoldings[myHoldings.size()-1]
	
	for item in myHoldings:
		if(item.CurrentPlayerColor != lastValue.CurrentPlayerColor):
			return true
		pass
	
	return false

func RemoveMyRef(p)->void:
	myHoldings.erase(p)
	pass
# wait for development progress..
