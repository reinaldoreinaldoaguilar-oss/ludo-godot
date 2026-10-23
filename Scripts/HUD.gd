extends Control
## Interfaz de la partida: tarjetas de jugadores, banner de turno, pistas junto
## al dado, mensajes emergentes, menú de pausa y pantalla final con estadísticas.

const MENU_SCENE := "res://Scenes/menu_principal.tscn"
const LEVEL_SCENE := "res://Levels/Level_MainGamePlay.tscn"
const DIFF_NAMES := ["Fácil", "Normal", "Difícil"]

var board: BoardManager
var cards: Dictionary = {} # color -> {panel, dots, points, status}
var banner: PanelContainer
var banner_label: Label
var hint_label: Label
var dice_value_label: Label
var toast_box: VBoxContainer
var pause_layer: Control
var end_layer: Control

func _ready() -> void:
	theme = UITheme.get_theme()
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	process_mode = Node.PROCESS_MODE_ALWAYS
	board = get_tree().get_first_node_in_group("Tablero")
	build_player_cards()
	build_top_bar()
	build_dice_area()
	build_pause_menu()
	board.turn_started.connect(_on_turn_started)
	board.dice_result.connect(_on_dice_result)
	board.waiting_for_piece.connect(_on_waiting_for_piece)
	board.game_message.connect(show_toast)
	board.stats_changed.connect(func(_s): refresh_cards())
	board.piece_reached_home.connect(func(_p): refresh_cards())
	board.game_over.connect(_on_game_over)

# ---------------------------------------------------------------- Construcción

func label(text: String, size: int, color: Color = UITheme.TEXT, weight: int = 700) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_font_override("font", UITheme.font(weight))
	return l

func build_player_cards() -> void:
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	column.position = Vector2(16, 80)
	column.custom_minimum_size = Vector2(250, 0)
	add_child(column)
	for j in GameManager.jugadores:
		var color: int = j["color"]
		var panel := PanelContainer.new()
		panel.add_theme_stylebox_override("panel", UITheme.box(UITheme.PANEL_BG, 16, GameManager.COLOR_VALUES[color].darkened(0.3), 2, 12))
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		var dot := Panel.new()
		dot.custom_minimum_size = Vector2(16, 16)
		dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		dot.add_theme_stylebox_override("panel", UITheme.box(GameManager.COLOR_VALUES[color], 8, Color.TRANSPARENT, 0, 0))
		row.add_child(dot)
		var info := VBoxContainer.new()
		info.add_theme_constant_override("separation", 2)
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info.add_child(label(j["nombre"], 17, UITheme.TEXT, 800))
		var kind: String = "Bot · " + DIFF_NAMES[GameManager.dificultad] if j["es_bot"] else "Humano"
		var status := label(kind, 13, UITheme.TEXT_MUTED, 600)
		info.add_child(status)
		var dots := HBoxContainer.new()
		dots.add_theme_constant_override("separation", 4)
		for i in 4:
			var d := Panel.new()
			d.custom_minimum_size = Vector2(12, 12)
			dots.add_child(d)
		info.add_child(dots)
		row.add_child(info)
		var points := label("0 pts", 15, Color("ffd32a"), 800)
		row.add_child(points)
		panel.add_child(row)
		column.add_child(panel)
		cards[color] = {"panel": panel, "dots": dots, "points": points, "status": status}
	refresh_cards()

func build_top_bar() -> void:
	var btn_pause := Button.new()
	btn_pause.text = "Pausa"
	btn_pause.add_theme_font_size_override("font_size", 16)
	btn_pause.position = Vector2(16, 16)
	btn_pause.pressed.connect(toggle_pause)
	add_child(btn_pause)

	banner = PanelContainer.new()
	banner.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	banner.position.y = 12
	banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	banner_label = label("", 22, UITheme.TEXT, 900)
	banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.add_child(banner_label)
	add_child(banner)


func build_dice_area() -> void:
	var area := VBoxContainer.new()
	area.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	area.offset_left = -270
	area.offset_right = -16
	area.offset_top = 10
	area.offset_bottom = 300
	area.alignment = BoxContainer.ALIGNMENT_BEGIN
	area.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dice_value_label = label("", 46, Color.WHITE, 900)
	dice_value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	area.add_child(dice_value_label)
	hint_label = label("", 18, UITheme.TEXT, 700)
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	area.add_child(hint_label)
	toast_box = VBoxContainer.new()
	toast_box.add_theme_constant_override("separation", 8)
	toast_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	area.add_child(toast_box)
	add_child(area)

func build_pause_menu() -> void:
	pause_layer = overlay()
	var panel := centered_panel(pause_layer, 360)
	var box: VBoxContainer = panel.get_child(0)
	box.add_child(title("Pausa"))
	box.add_child(button("Continuar", toggle_pause))
	box.add_child(button("Reiniciar partida", func(): change_scene(LEVEL_SCENE)))
	box.add_child(button("Salir al menú", func(): change_scene(MENU_SCENE)))
	pause_layer.hide()

func overlay() -> Control:
	var layer := ColorRect.new()
	layer.color = Color(0, 0, 0, 0.55)
	layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(layer)
	return layer

func centered_panel(parent: Control, width: float) -> PanelContainer:
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	parent.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(width, 0)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	panel.add_child(box)
	center.add_child(panel)
	return panel

func title(text: String) -> Label:
	var l := label(text, 30, UITheme.TEXT, 900)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return l

func button(text: String, action: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, 48)
	b.pressed.connect(func():
		AudioManager.play("click")
		action.call())
	return b

# ---------------------------------------------------------------- Actualización

func refresh_cards() -> void:
	for color in cards:
		var group: PlayerPiecesGroup = board.piecesManager.GetPieceGroupBasedOnType(color) if board else null
		var home: int = group.pieces_home() if group else 0
		var dots: HBoxContainer = cards[color]["dots"]
		for i in 4:
			var filled := i < home
			var c: Color = GameManager.COLOR_VALUES[color] if filled else Color(1, 1, 1, 0.15)
			dots.get_child(i).add_theme_stylebox_override("panel", UITheme.box(c, 6, Color.TRANSPARENT, 0, 0))
		var pts: int = board.stats[color]["puntos"] if board and board.stats.has(color) else 0
		cards[color]["points"].text = "%d pts" % pts

func highlight_card(active: int) -> void:
	for color in cards:
		var panel: PanelContainer = cards[color]["panel"]
		var is_active: bool = color == active
		var c: Color = GameManager.COLOR_VALUES[color]
		var bg := c.darkened(0.55) if is_active else UITheme.PANEL_BG
		panel.add_theme_stylebox_override("panel", UITheme.box(bg, 16, c if is_active else c.darkened(0.3), 3 if is_active else 2, 12))
		panel.pivot_offset = panel.size / 2
		panel.create_tween().tween_property(panel, "scale", Vector2(1.05, 1.05) if is_active else Vector2.ONE, 0.2)

func _on_turn_started(color: int, is_bot: bool) -> void:
	highlight_card(color)
	var c: Color = GameManager.COLOR_VALUES[color]
	banner.add_theme_stylebox_override("panel", UITheme.box(c.darkened(0.25), 20, c.lightened(0.3), 2, 12))
	banner_label.text = "Turno de " + GameManager.get_nombre(color)
	banner.reset_size()
	banner.position.x = (size.x - banner.size.x) / 2
	UITheme.pop_in(banner, 0.3)
	dice_value_label.text = ""
	hint_label.text = "Pensando..." if is_bot else "Toca el dado\n(o pulsa Espacio)"

func _on_dice_result(color: int, value: int) -> void:
	dice_value_label.text = str(value)
	dice_value_label.add_theme_color_override("font_color", GameManager.COLOR_VALUES[color].lightened(0.2))
	UITheme.pop_in(dice_value_label, 0.25)
	if GameManager.is_bot(color):
		hint_label.text = "Sacó un %d" % value
	else:
		hint_label.text = "Sacaste un %d" % value

func _on_waiting_for_piece(_color: int, movable: Array) -> void:
	hint_label.text = "Elige una ficha resaltada" if movable.size() > 1 else "Toca la ficha resaltada"

func show_toast(text: String, color: int) -> void:
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var c: Color = GameManager.COLOR_VALUES.get(color, UITheme.ACCENT)
	panel.add_theme_stylebox_override("panel", UITheme.box(Color(0.08, 0.09, 0.14, 0.92), 14, c, 2, 10))
	var l := label(text, 17, UITheme.TEXT, 700)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(l)
	toast_box.add_child(panel)
	while toast_box.get_child_count() > 3:
		toast_box.get_child(0).free()
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	await get_tree().process_frame
	UITheme.pop_in(panel, 0.25)
	var tw := panel.create_tween()
	tw.tween_interval(2.8)
	tw.tween_property(panel, "modulate:a", 0.0, 0.4)
	tw.tween_callback(panel.queue_free)

func toggle_pause() -> void:
	if end_layer and end_layer.visible:
		return
	var paused := not get_tree().paused
	get_tree().paused = paused
	pause_layer.visible = paused
	if paused:
		UITheme.pop_in(pause_layer.get_child(0).get_child(0))

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func change_scene(path: String) -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(path)

# ---------------------------------------------------------------- Fin de partida

func _on_game_over(ranking: Array) -> void:
	hint_label.text = ""
	await get_tree().create_timer(0.8, false).timeout
	end_layer = overlay()
	var panel := centered_panel(end_layer, 620)
	var box: VBoxContainer = panel.get_child(0)
	var winner: int = ranking[0]
	box.add_child(title("¡Ganó %s!" % GameManager.get_nombre(winner)))
	var grid := GridContainer.new()
	grid.columns = 6
	grid.add_theme_constant_override("h_separation", 18)
	grid.add_theme_constant_override("v_separation", 8)
	for h in ["#", "Jugador", "Capturas", "Seises", "Trivia", "Puntos"]:
		grid.add_child(label(h, 14, UITheme.TEXT_MUTED, 800))
	var medals := ["1°", "2°", "3°", "4°"]
	for i in ranking.size():
		var color: int = ranking[i]
		var s: Dictionary = board.stats[color]
		grid.add_child(label(medals[i], 18))
		grid.add_child(label(GameManager.get_nombre(color), 17, GameManager.COLOR_VALUES[color].lightened(0.2), 800))
		grid.add_child(label(str(s["capturas"]), 17))
		grid.add_child(label(str(s["seises"]), 17))
		grid.add_child(label("%d/%d" % [s["trivia_ok"], s["trivia_total"]], 17))
		grid.add_child(label(str(s["puntos"]), 17, Color("ffd32a")))
	var center := CenterContainer.new()
	center.add_child(grid)
	box.add_child(center)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	var again := button("Jugar otra vez", func(): change_scene(LEVEL_SCENE))
	again.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var menu := button("Menú principal", func(): change_scene(MENU_SCENE))
	menu.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(again)
	row.add_child(menu)
	box.add_child(row)
	UITheme.pop_in(panel, 0.5)
	Effects.confetti(end_layer)
