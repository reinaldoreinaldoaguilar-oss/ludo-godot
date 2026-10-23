class_name Dice
extends Node2D
## Dado: anima la tirada y emite el resultado. No conoce las reglas del juego;
## BoardManager decide cuándo se puede tirar (enabled) y qué pasa después.

@export var Maindice: Sprite2D
@export var DicesSpriteArray: Array[Texture2D]
@export var IsTestRun: bool ## Si está activo, siempre sale 6 (para pruebas).
@export var IsAutoDiceRoll: bool ## Obsoleto: los bots ahora los controla BoardManager.

signal OnDiceRolled(value: int)
signal OnDiceRollBegin

## Si es true, el jugador humano puede tocar el dado.
var enabled: bool = false
var rolling: bool = false
var rng := RandomNumberGenerator.new()

## Permite forzar resultados en los tests automáticos.
var forced_values: Array[int] = []

func _enter_tree() -> void:
	add_to_group("Dado")

func _ready() -> void:
	rng.randomize()

func SetSpriteByIndex(index: int) -> void:
	Maindice.texture = DicesSpriteArray[clampi(index, 0, DicesSpriteArray.size() - 1)]

func RollDice() -> void:
	if rolling:
		return
	rolling = true
	enabled = false
	OnDiceRollBegin.emit()
	await AnimateDice()
	var value := rng.randi_range(1, 6)
	if not forced_values.is_empty():
		value = forced_values.pop_front()
	elif IsTestRun:
		value = 6
	SetSpriteByIndex(value - 1)
	rolling = false
	OnDiceRolled.emit(value)

func _input(event: InputEvent) -> void:
	if not enabled or rolling:
		return
	if event.is_action_pressed("DiceClick") and Maindice.is_pixel_opaque(Maindice.get_local_mouse_position()):
		get_viewport().set_input_as_handled()
		RollDice()

func AnimateDice() -> void:
	for i in 8:
		SetSpriteByIndex(rng.randi_range(0, 5))
		await get_tree().create_timer(0.07, false).timeout
