class_name UITheme
extends RefCounted
## Tema visual moderno compartido por menús, HUD y trivia (botones redondeados,
## paneles translúcidos y la fuente Nunito).

const FONT_PATH := "res://Arts/Fonts/Nunito-Variable.ttf"
const ACCENT := Color("ff4757")
const ACCENT_HOVER := Color("ff6b81")
const PANEL_BG := Color(0.08, 0.09, 0.14, 0.88)
const TEXT := Color("f5f6fa")
const TEXT_MUTED := Color("a4b0be")

static var _theme: Theme

static func font(weight: int = 600) -> Font:
	var base: FontFile = load(FONT_PATH)
	var variation := FontVariation.new()
	variation.base_font = base
	variation.variation_opentype = {TextServerManager.get_primary_interface().name_to_tag("wght"): weight}
	return variation

static func box(color: Color, radius: int = 18, border: Color = Color.TRANSPARENT, border_width: int = 0, padding: int = 14) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.set_corner_radius_all(radius)
	sb.set_content_margin_all(padding)
	if border_width > 0:
		sb.border_color = border
		sb.set_border_width_all(border_width)
	sb.anti_aliasing = true
	return sb

static func get_theme() -> Theme:
	if _theme:
		return _theme
	var t := Theme.new()
	t.default_font = font(600)
	t.default_font_size = 20

	var normal := box(ACCENT, 16, Color(1, 1, 1, 0.25), 2, 12)
	normal.shadow_color = Color(0, 0, 0, 0.35)
	normal.shadow_size = 6
	normal.shadow_offset = Vector2(0, 4)
	var hover := normal.duplicate()
	hover.bg_color = ACCENT_HOVER
	var pressed := normal.duplicate()
	pressed.bg_color = ACCENT.darkened(0.2)
	pressed.shadow_offset = Vector2(0, 1)
	var disabled := normal.duplicate()
	disabled.bg_color = Color(0.4, 0.4, 0.45, 0.8)
	var focus := box(Color.TRANSPARENT, 16, Color.WHITE, 3, 12)
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		var sb: StyleBox = {"normal": normal, "hover": hover, "pressed": pressed, "disabled": disabled, "focus": focus}[state]
		t.set_stylebox(state, "Button", sb)
	t.set_color("font_color", "Button", TEXT)
	t.set_color("font_hover_color", "Button", Color.WHITE)
	t.set_color("font_pressed_color", "Button", Color.WHITE)
	t.set_font("font", "Button", font(800))

	t.set_stylebox("panel", "PanelContainer", box(PANEL_BG, 24, Color(1, 1, 1, 0.08), 2, 24))
	t.set_stylebox("panel", "Panel", box(PANEL_BG, 24, Color(1, 1, 1, 0.08), 2, 24))
	t.set_color("font_color", "Label", TEXT)
	t.set_color("default_color", "RichTextLabel", TEXT)
	t.set_font("normal_font", "RichTextLabel", font(500))
	t.set_font("bold_font", "RichTextLabel", font(800))

	var bar_bg := box(Color(1, 1, 1, 0.12), 8, Color.TRANSPARENT, 0, 0)
	var bar_fill := box(Color("2ed573"), 8, Color.TRANSPARENT, 0, 0)
	t.set_stylebox("background", "ProgressBar", bar_bg)
	t.set_stylebox("fill", "ProgressBar", bar_fill)

	var slider := box(Color(1, 1, 1, 0.2), 6, Color.TRANSPARENT, 0, 0)
	slider.content_margin_top = 4
	slider.content_margin_bottom = 4
	t.set_stylebox("slider", "HSlider", slider)
	var grab := box(ACCENT, 6, Color.TRANSPARENT, 0, 0)
	t.set_stylebox("grabber_area", "HSlider", grab)
	t.set_stylebox("grabber_area_highlight", "HSlider", grab)

	var option := normal.duplicate()
	option.bg_color = Color(1, 1, 1, 0.12)
	option.shadow_size = 0
	t.set_stylebox("normal", "OptionButton", option)
	var option_hover := option.duplicate()
	option_hover.bg_color = Color(1, 1, 1, 0.2)
	t.set_stylebox("hover", "OptionButton", option_hover)
	t.set_stylebox("pressed", "OptionButton", option_hover)
	t.set_stylebox("focus", "OptionButton", focus)
	t.set_stylebox("panel", "PopupMenu", box(Color(0.12, 0.13, 0.19), 12, Color(1, 1, 1, 0.1), 1, 8))
	t.set_stylebox("normal", "LineEdit", box(Color(1, 1, 1, 0.1), 10, Color(1, 1, 1, 0.15), 1, 10))
	t.set_stylebox("focus", "LineEdit", box(Color(1, 1, 1, 0.14), 10, ACCENT, 2, 10))
	t.set_color("font_color", "LineEdit", TEXT)
	t.set_font_size("font_size", "LineEdit", 17)
	t.set_font_size("font_size", "OptionButton", 17)
	t.set_font_size("font_size", "SpinBox", 17)
	var empty := StyleBoxEmpty.new()
	for state in ["normal", "hover", "pressed", "hover_pressed", "focus"]:
		t.set_stylebox(state, "CheckButton", empty)
	t.set_color("font_color", "CheckButton", TEXT)
	t.set_color("font_hover_color", "CheckButton", Color.WHITE)
	t.set_color("font_pressed_color", "CheckButton", TEXT)
	t.set_color("font_hover_pressed_color", "CheckButton", Color.WHITE)
	_theme = t
	return t

## Botón con estilo propio de un color (por ejemplo, el de un jugador).
static func colored_button(button: Button, color: Color) -> void:
	for state in ["normal", "hover", "pressed"]:
		var c := color
		if state == "hover": c = color.lightened(0.15)
		elif state == "pressed": c = color.darkened(0.2)
		var sb := box(c, 16, Color(1, 1, 1, 0.25), 2, 12)
		button.add_theme_stylebox_override(state, sb)

## Animación de "pop" al aparecer.
static func pop_in(node: Control, duration: float = 0.35) -> void:
	node.pivot_offset = node.size / 2
	node.scale = Vector2(0.85, 0.85)
	node.modulate.a = 0.0
	var tw := node.create_tween().set_parallel().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(node, "scale", Vector2.ONE, duration)
	tw.tween_property(node, "modulate:a", 1.0, duration * 0.6)
