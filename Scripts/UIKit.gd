class_name UIKit
extends RefCounted
## Constructores de controles con el estilo del juego (evita repetir código en
## el menú, el HUD y los paneles).

static func label(text: String, size: int = 18, color: Color = UITheme.TEXT, weight: int = 700) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_font_override("font", UITheme.font(weight))
	return l

static func title(text: String, size: int = 30) -> Label:
	var l := label(text, size, UITheme.TEXT, 900)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return l

static func button(text: String, action: Callable, height: float = 48) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, height)
	b.pressed.connect(func():
		AudioManager.play("click")
		action.call())
	return b

## Capa oscura que cubre la pantalla y bloquea los clics de abajo.
static func overlay(parent: Control, alpha: float = 0.6) -> ColorRect:
	var layer := ColorRect.new()
	layer.color = Color(0, 0, 0, alpha)
	layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	parent.add_child(layer)
	return layer

## Panel centrado con un VBoxContainer dentro (devuelve el VBox).
static func centered_box(parent: Control, width: float, separation: int = 12) -> VBoxContainer:
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	parent.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(width, 0)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", separation)
	panel.add_child(box)
	center.add_child(panel)
	return box

static func row(children: Array, separation: int = 12) -> HBoxContainer:
	var r := HBoxContainer.new()
	r.add_theme_constant_override("separation", separation)
	for c in children:
		r.add_child(c)
	return r

static func expand(c: Control) -> Control:
	c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return c

static func option(items: Array, selected: int, on_change: Callable) -> OptionButton:
	var o := OptionButton.new()
	for it in items:
		o.add_item(it)
	o.selected = selected
	o.custom_minimum_size = Vector2(0, 40)
	o.item_selected.connect(func(i):
		AudioManager.play("click")
		on_change.call(i))
	return o
