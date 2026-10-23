class_name Dice
extends Node2D
## Dado: anima la tirada y emite el resultado. No conoce las reglas del juego;
## BoardManager decide cuándo se puede tirar (enabled) y qué pasa después.
## Se tira con clic/toque sobre el dado o con la barra espaciadora.

@export var Maindice: Sprite2D
@export var DicesSpriteArray: Array[Texture2D]
@export var IsTestRun: bool ## Si está activo, siempre sale 6 (para pruebas).
@export var IsAutoDiceRoll: bool ## Obsoleto: los bots ahora los controla BoardManager.

signal OnDiceRolled(value: int)
signal OnDiceRollBegin

## Si es true, el jugador humano puede tirar.
var enabled: bool = false:
	set(value):
		enabled = value
		_time = 0.0
		queue_redraw()
var rolling: bool = false
var glow_color: Color = Color.WHITE
var rng := RandomNumberGenerator.new()
var forced_values: Array[int] = [] ## Permite forzar resultados en los tests.
var _time: float = 0.0

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
	Maindice.scale = Vector2.ONE
	OnDiceRollBegin.emit()
	AudioManager.play("dice_roll", 0.05)
	await AnimateDice()
	var value := rng.randi_range(1, 6)
	if not forced_values.is_empty():
		value = forced_values.pop_front()
	elif IsTestRun:
		value = 6
	SetSpriteByIndex(value - 1)
	AudioManager.play("dice_land")
	var tw := create_tween()
	tw.tween_property(Maindice, "scale", Vector2(1.3, 1.3), 0.08)
	tw.tween_property(Maindice, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	rolling = false
	OnDiceRolled.emit(value)

func _input(event: InputEvent) -> void:
	if not enabled or rolling or not event.is_action_pressed("DiceClick"):
		return
	if event is InputEventKey or Maindice.is_pixel_opaque(Maindice.get_local_mouse_position()):
		get_viewport().set_input_as_handled()
		RollDice()

func AnimateDice() -> void:
	var tw := create_tween().set_parallel()
	tw.tween_property(Maindice, "rotation", TAU * 2, 0.55).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(Maindice, "position", Vector2(0, -60), 0.27).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.chain().tween_property(Maindice, "position", Vector2.ZERO, 0.25).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	for i in 8:
		SetSpriteByIndex(rng.randi_range(0, 5))
		await get_tree().create_timer(0.07, false).timeout
	if tw.is_running():
		await tw.finished
	Maindice.rotation = 0.0

func _process(delta: float) -> void:
	if enabled:
		_time += delta
		queue_redraw()

## Halo pulsante cuando es el turno de un humano.
func _draw() -> void:
	if not enabled:
		return
	var c := glow_color
	var r := 140.0 + sin(_time * 5.0) * 10.0
	c.a = 0.25
	draw_circle(Vector2.ZERO, r, c)
	c.a = 0.9
	draw_arc(Vector2.ZERO, r, 0, TAU, 64, c, 8.0, true)
