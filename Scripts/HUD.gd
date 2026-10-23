extends Control
## Interfaz durante la partida: indicador de turno, mensajes, botón de menú
## y pantalla final con el ranking.

const MENU_SCENE := "res://Scenes/menu_principal.tscn"

var board: BoardManager
var turn_label: Label
var message_label: Label
var end_panel: PanelContainer
var end_label: Label

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	build_ui()
	board = get_tree().get_first_node_in_group("Tablero")
	board.turn_started.connect(_on_turn_started)
	board.dice_result.connect(_on_dice_result)
	board.waiting_for_piece.connect(_on_waiting_for_piece)
	board.game_message.connect(_on_game_message)
	board.game_over.connect(_on_game_over)

func build_ui() -> void:
	var btn_menu := Button.new()
	btn_menu.text = "Menú"
	btn_menu.position = Vector2(20, 20)
	btn_menu.pressed.connect(func(): get_tree().change_scene_to_file(MENU_SCENE))
	add_child(btn_menu)

	turn_label = Label.new()
	turn_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	turn_label.position.y = 20
	turn_label.add_theme_font_size_override("font_size", 26)
	add_child(turn_label)

	message_label = Label.new()
	message_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	message_label.position.y -= 60
	message_label.add_theme_font_size_override("font_size", 22)
	add_child(message_label)

	end_panel = PanelContainer.new()
	end_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	end_panel.hide()
	var box := VBoxContainer.new()
	end_label = Label.new()
	box.add_child(end_label)
	var btn_volver := Button.new()
	btn_volver.text = "Volver al menú"
	btn_volver.pressed.connect(func(): get_tree().change_scene_to_file(MENU_SCENE))
	box.add_child(btn_volver)
	end_panel.add_child(box)
	add_child(end_panel)

func _on_turn_started(color: int, is_bot: bool) -> void:
	turn_label.text = "Turno: %s" % GameManager.get_nombre(color)
	turn_label.add_theme_color_override("font_color", GameManager.COLOR_VALUES[color])
	message_label.text = "Pensando..." if is_bot else "Toca el dado para tirar"

func _on_dice_result(_color: int, value: int) -> void:
	message_label.text = "Sacaste un %d" % value

func _on_waiting_for_piece(_color: int, _movable: Array) -> void:
	message_label.text = "Elige una ficha"

func _on_game_message(text: String, _color: int) -> void:
	message_label.text = text

func _on_game_over(ranking: Array) -> void:
	var text := "Fin de la partida\n\n"
	for i in ranking.size():
		text += "%d. %s\n" % [i + 1, GameManager.get_nombre(ranking[i])]
	end_label.text = text
	end_panel.show()
