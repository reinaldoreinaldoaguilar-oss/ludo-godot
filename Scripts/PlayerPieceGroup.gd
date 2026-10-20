class_name PlayerPiecesGroup
extends Node2D

@export var Pieces: Array[Piece]
@export var PlayerFirstPosition:int
@export var CurrentPlayerColor:GameManager.PlayerColor
@export var IsAutoPieceSelect:bool

var boardManager:BoardManager

func _ready() -> void:
	boardManager = get_tree().get_first_node_in_group("BoardManager")

	# --- CONTROL ESTRICTO DE BOTS ---
	if GameManager.modo_contra_bots:
		if CurrentPlayerColor == GameManager.PlayerColor.Green:
			IsAutoPieceSelect = false # FORZAMOS A QUE EL VERDE SEA MANUAL (TÚ)
		else:
			IsAutoPieceSelect = true  # FORZAMOS A QUE LOS DEMÁS SEAN BOTS
	else:
		IsAutoPieceSelect = false # EN MULTIJUGADOR LOCAL, TODOS SON MANUALES
	# --------------------------------

	for i in range(0,Pieces.size()):
		Pieces[i].SetStartPosition(PlayerFirstPosition)
		Pieces[i].CurrentState = GameManager.PieceStateEnum.InLobby
		pass
		
	# Solo conectamos la señal de la IA si realmente es un bot
	if IsAutoPieceSelect:
		GameManager.OnGameCurrentStateChange.connect(_on_game_current_state_change)
		pass
	pass

#AI for testing.
func _on_game_current_state_change(updatedState:GameManager.GameStateEnum)->void:
	if IsAutoPieceSelect && boardManager.currentPlayerColor == CurrentPlayerColor:
		match updatedState:
			GameManager.GameStateEnum.PlayerSelectPiece:
				await get_tree().create_timer(2).timeout
				var mypiece = GetPieceForAI()
				if mypiece != null:
					mypiece.AIInput()
				pass
			pass
		pass
	pass

func GetPieceForAI()->Piece:
	var randomNum:int = RandomNumberGenerator.new().randf_range(0,4)
	
	if Pieces[randomNum].IsInHome:
		var tempCheck:bool = HasThisPlayerCompleted()
		if tempCheck:
			GetPieceForAI()
			pass
		else:
			return null
		pass
			
	return Pieces[randomNum]

func GetPieceByIndex(index:int)->Piece:
	if(index>=4):
		return null

	return Pieces[index]

func HasThisPlayerCompleted()->bool:
	for item:Piece in Pieces:
		if item.IsInHome == false:
			return false
		pass
	return true

func HasUnlockedAnyPiece()->bool:
	for piece in Pieces:
		if(piece.CurrentState != GameManager.PieceStateEnum.InLobby):
			return true
	return false

func PlayAllPieceAnimation()->void:
	for i in range(0,Pieces.size()):
		if(Pieces[i].CurrentState!=GameManager.PieceStateEnum.InHouse):
			Pieces[i].PlayAnimation()
			pass
		pass
	pass

func StopAllPieceAnimation()->void:
	for i in range(0,Pieces.size()):
		Pieces[i].StopAnimation()
		pass
	pass
