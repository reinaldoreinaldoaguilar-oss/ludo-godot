class_name BoardManager
extends Node2D

@export var way_points: WayPointsManager
@export var piecesManager: PiecesManager
@export var animation_PlayerForPlaces: AnimationPlayer

var currentPlayerTurnIndex:int = -1
var currentDiceValue:int = -1
var currentAnimationPlaceName:String = ""
var hasKill:bool = false
var currentPlayerColor:GameManager.PlayerColor

signal OnHasKill

func _ready() -> void:
	add_to_group("Tablero") 
	UpdatePlayerTurn()
	GameManager.OnPlayerSelectPiece.connect(_on_player_select_piece)
	
	# --- BOTÓN DE SALIR AUTOMÁTICO ---
	var canvas = CanvasLayer.new()
	var btn_salir = Button.new()
	btn_salir.text = "SALIR AL MENÚ"
	btn_salir.position = Vector2(20, 20)
	btn_salir.add_theme_font_size_override("font_size", 24)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.8, 0.1, 0.1, 1.0) 
	btn_salir.add_theme_stylebox_override("normal", style)
	
	btn_salir.pressed.connect(func(): get_tree().change_scene_to_file("res://menu_principal.tscn"))
	
	canvas.add_child(btn_salir)
	add_child(canvas)
	# ---------------------------------
	pass

func _on_player_select_piece(value:Piece) ->void:
	print("on player select piece__",value.get_parent().name)

	var playerType = value.CurrentPlayerColor
	var isPlayerTurn = IsThisPlayerTurn(playerType)
	
	if(isPlayerTurn):
		# --- REGLA 1: CANDADO DE LA BASE ---
		if value.CurrentState == GameManager.PieceStateEnum.InLobby and currentDiceValue != 6:
			print("¡Necesitas un 6 para sacar una ficha de la base!")
			return 
		# -----------------------------------
		
		StopPieceAnimation()
		MovePieces(currentDiceValue,value)	
		pass
	else: 
		push_error("is player turn is false!!!!!!",isPlayerTurn)
		pass
	pass
	
func IsThisPlayerTurn(playerType:GameManager.PlayerColor)->bool:
	var returnValue:bool = false
	
	match playerType:
		GameManager.PlayerColor.Green:
			returnValue = (currentPlayerTurnIndex == 0)
			pass
		GameManager.PlayerColor.Yellow:
			returnValue = (currentPlayerTurnIndex == 1)
			pass
		GameManager.PlayerColor.Blue:
			returnValue = (currentPlayerTurnIndex == 2)
			pass
		GameManager.PlayerColor.Red:
			returnValue = (currentPlayerTurnIndex == 3)
			pass
	
	return returnValue

func _on_dice_root_on_dice_roll_begin() -> void:
	animation_PlayerForPlaces.stop()
	pass 

func _on_dice_root_on_dice_rolled(value: int) -> void:
	print("diceRolled! Value is ",value)
	currentDiceValue = value
		
	if(currentDiceValue !=6 && piecesManager.HasThisPlayerUnlockedTurn(currentPlayerColor) == false):
		print("skip this player turn because this player has not unlocked any piece yet")
		UpdatePlayerTurn()
		GameManager.UpdateGameCurrentState(GameManager.GameStateEnum.PlayerCanRollDice)
		print("Game state ",GameManager.GameCurrentState)
		return

	PlayPieceAnimation()
	pass 
	
func MovePieces(valor_dado: int, moveThisPiece: Piece) -> void:
	print("move piece: ", valor_dado)
	
	var posicion_anterior = moveThisPiece.GetCurrentPosition()
	var posicion_final = valor_dado + posicion_anterior
	var estaba_en_base = (moveThisPiece.CurrentState == GameManager.PieceStateEnum.InLobby)
	
	# --- REGLA 2: SALIDA A LA CASILLA DE INICIO ---
	if estaba_en_base:
		posicion_final = 0 
	elif posicion_final >= 57:
		posicion_final = 57
	# ----------------------------------------------
		
	GameManager.UpdateGameCurrentState(GameManager.GameStateEnum.Null)
	
	# Animación paso a paso
	if estaba_en_base:
		moveThisPiece.position = way_points.GetPositionOfThisPoint(0, moveThisPiece.CurrentPlayerColor)
		await get_tree().create_timer(0.5).timeout
	else:
		for i in range(posicion_anterior, posicion_final):
			moveThisPiece.position = way_points.GetPositionOfThisPoint(i + 1,moveThisPiece.CurrentPlayerColor)
			await get_tree().create_timer(0.2).timeout 
	
	# --- INTEGRACIÓN TRIVIA EN ESTRELLAS ---
	var indice_real = posicion_final
	if posicion_final == 57: 
		indice_real = 56
		
	var waypoint_destino: WayPoint = null
	match moveThisPiece.CurrentPlayerColor:
		GameManager.PlayerColor.Green: waypoint_destino = way_points.green_path[indice_real]
		GameManager.PlayerColor.Yellow: waypoint_destino = way_points.yellow_path[indice_real]
		GameManager.PlayerColor.Blue: waypoint_destino = way_points.blue_path[indice_real]
		GameManager.PlayerColor.Red: waypoint_destino = way_points.red_path[indice_real]
		
	# Chequeo si el jugador actual es un Bot
	var es_bot = (GameManager.modo_contra_bots and moveThisPiece.CurrentPlayerColor != GameManager.PlayerColor.Green)
		
	if waypoint_destino != null and waypoint_destino.isThisSafePlace and not estaba_en_base and not es_bot:
		print("¡Cayó en una estrella! Activando Trivia...")
		var ventana = get_tree().get_first_node_in_group("Trivia")
		if ventana != null:
			var categorias = ["futbol", "estructuras", "cultura"]
			ventana.cargar_pregunta(categorias.pick_random())
			ventana.show()
			
			var es_correcta = await ventana.respondido
			if not es_correcta:
				print("¡Falló la trivia! La ficha rebota a su posición anterior.")
				# Castigo paso a paso
				for i in range(posicion_final, posicion_anterior - 1, -1):
					moveThisPiece.position = way_points.GetPositionOfThisPoint(i, moveThisPiece.CurrentPlayerColor)
					await get_tree().create_timer(0.2).timeout 
					
				posicion_final = posicion_anterior
	# ---------------------------------------
	
	if posicion_final == 57:
		moveThisPiece.SetCurrentPositionAndCheckKill(56)
	else:
		moveThisPiece.SetCurrentPositionAndCheckKill(posicion_final)
	
	if (hasKill):
		await OnHasKill
		
	moveThisPiece.CurrentState = GameManager.PieceStateEnum.InWayPoint
	
	GameManager.UpdateGameCurrentState(GameManager.GameStateEnum.PlayerCanRollDice)
	
	# --- REGLA 3: TURNO EXTRA POR SACAR 6 ---
	if valor_dado == 6:
		print("¡Sacó un 6! Repite el turno.")
		PlayPlaceAnimation() 
	else:
		UpdatePlayerTurn() 
	# ----------------------------------------
	pass

func MovePiecesToHome(value: int, moveThisPiece: Piece) -> void:
	for i in range(moveThisPiece.GetCurrentPosition()-1,value-1,-1):
		print("back move ",i,"__",moveThisPiece.CurrentPlayerColor)
		moveThisPiece.position = way_points.GetPositionOfThisPoint(i,moveThisPiece.CurrentPlayerColor)
		await get_tree().create_timer(0.3).timeout
		
	moveThisPiece.CurrentPosition = value
	moveThisPiece.CurrentState = GameManager.PieceStateEnum.InWayPoint
	
	OnHasKill.emit()
	pass

func UpdatePlayerTurn() -> void:
	print("Update player turn......")
	currentPlayerTurnIndex+=1
	
	if(currentPlayerTurnIndex >=4):
		currentPlayerTurnIndex=0
		pass

	match currentPlayerTurnIndex:
		0:
			currentPlayerColor = GameManager.PlayerColor.Green
			pass
		1:
			currentPlayerColor = GameManager.PlayerColor.Yellow
			pass
		2:
			currentPlayerColor = GameManager.PlayerColor.Blue
			pass
		3:
			currentPlayerColor = GameManager.PlayerColor.Red
			pass
	
	print("color is ",currentPlayerColor)
	
	if piecesManager.IsGameOver():
		print("is game over!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
		return
	
	var pieceGroup = piecesManager.GetPieceGroupBasedOnType(currentPlayerColor)
	
	if pieceGroup!=null && pieceGroup.HasThisPlayerCompleted() == true:
		print("update player turn again because ",currentPlayerColor," has completed game")
		UpdatePlayerTurn()
		return
		
	PlayPlaceAnimation()
	pass

func PlayPlaceAnimation()-> void:
	match(currentPlayerTurnIndex):
		0:
			currentAnimationPlaceName = "GreenPlaceAnimation"
			pass
		1:
			currentAnimationPlaceName = "YellowPlaceAnimation"
			pass
		2: 
			currentAnimationPlaceName = "BluePlaceAnimation"
			pass
		3:
			currentAnimationPlaceName = "RedPlaceAnimation"
			pass
			
	animation_PlayerForPlaces.stop()
	animation_PlayerForPlaces.play(currentAnimationPlaceName)
	pass

func PlayPieceAnimation()-> void:
	piecesManager.PlayAnimationByPlayerIndex(currentPlayerColor)
	pass

func StopPieceAnimation()-> void:
	piecesManager.StopAnimation()
	pass

func DetectKill(pieceToBeGoHome:Piece)->void:
	if(pieceToBeGoHome == null):
		hasKill = false
	else:
		print("sent ",pieceToBeGoHome.name," to home")
		hasKill = true	
		MovePiecesToHome(0,pieceToBeGoHome)
	pass
