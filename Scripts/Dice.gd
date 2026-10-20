class_name Dice
extends Node2D

@export var Maindice: Sprite2D
@export var DicesSpriteArray : Array[Texture2D]
@export var IsTestRun:bool 
@export var IsAutoDiceRoll:bool

signal OnDiceRolled(value: int)
signal OnDiceAniamtionComplate_Local
signal OnDiceRollBegin

func _ready() -> void:
	GameManager.OnGameCurrentStateChange.connect(_on_game_current_state_change)
	pass

func _on_game_current_state_change(updatedState:GameManager.GameStateEnum)-> void:
	match updatedState:
		GameManager.GameStateEnum.PlayerCanRollDice:
			var tablero = get_tree().get_first_node_in_group("Tablero")
			var es_turno_bot = false
			
			if tablero != null and GameManager.modo_contra_bots and tablero.currentPlayerColor != GameManager.PlayerColor.Green:
				es_turno_bot = true

			# IGNORAMOS EL IsAutoDiceRoll DEL EDITOR. SOLO GIRA SI ES BOT.
			if es_turno_bot:
				await get_tree().create_timer(1.0).timeout
				RollDice()
			pass
		pass
	pass

func SetSpriteByIndex(index: int) -> void:
	Maindice.texture = DicesSpriteArray[index]
	pass
	
func RollDice() -> void:
	if(GameManager.GameCurrentState == GameManager.GameStateEnum.PlayerCanRollDice):
		
		OnDiceRollBegin.emit()
		GameManager.UpdateGameCurrentState(GameManager.GameStateEnum.Null)

		var randomNumber = RandomNumberGenerator.new().randf_range(0,6)
		AnimateDice()
		
		await OnDiceAniamtionComplate_Local
		
		SetSpriteByIndex(int(randomNumber))
		
		var numero_final = int(randomNumber) + 1

		if(IsTestRun):
			numero_final = 6
			pass
			
		print("EL DADO SACÓ EXACTAMENTE UN: ", numero_final)
			
		if numero_final == 6:
			var ventana = get_tree().get_first_node_in_group("Trivia")
			var tablero = get_tree().get_first_node_in_group("Tablero")
			
			var es_bot = (tablero != null and GameManager.modo_contra_bots and tablero.currentPlayerColor != GameManager.PlayerColor.Green)
			
			if ventana != null and not es_bot:
				var categorias = ["futbol", "estructuras", "cultura"]
				ventana.cargar_pregunta(categorias.pick_random())
				ventana.show()
				
				var es_correcta = await ventana.respondido
				
				if not es_correcta:
					print("¡Falló la trivia! Pierde el tiro y pasa el turno.")
					if tablero != null:
						tablero.UpdatePlayerTurn()
					GameManager.UpdateGameCurrentState(GameManager.GameStateEnum.PlayerCanRollDice)
					return 

		GameManager.UpdateGameCurrentState(GameManager.GameStateEnum.PlayerSelectPiece)
		OnDiceRolled.emit(numero_final)
		pass
	pass
	
func _input(event: InputEvent) -> void:
	var diceClicked = event.is_action_pressed("DiceClick")
	var isClickedOnSprite = Maindice.is_pixel_opaque(Maindice.get_local_mouse_position())
	
	var tablero = get_tree().get_first_node_in_group("Tablero")
	var es_turno_bot = false
	if tablero != null and GameManager.modo_contra_bots and tablero.currentPlayerColor != GameManager.PlayerColor.Green:
		es_turno_bot = true
		
	if(diceClicked && isClickedOnSprite and not es_turno_bot):
		RollDice()
		pass
	pass
	
func AnimateDice() -> void:
	for i in range(0,6):
		await get_tree().create_timer(0.1).timeout
		var index = RandomNumberGenerator.new().randf_range(0,6)
		SetSpriteByIndex(int(index))
		pass
	OnDiceAniamtionComplate_Local.emit()
	pass
