class_name PanelReglas
extends ColorRect
## Ventana con las reglas del juego.

static func abrir(parent: Control) -> PanelReglas:
	var p := PanelReglas.new()
	parent.add_child(p)
	return p

func _ready() -> void:
	color = Color(0, 0, 0, 0.6)
	set_anchors_preset(Control.PRESET_FULL_RECT)
	process_mode = Node.PROCESS_MODE_ALWAYS
	var box := UIKit.centered_box(self, 640, 12)
	box.add_child(UIKit.title("Cómo se juega"))
	var text := RichTextLabel.new()
	text.bbcode_enabled = true
	text.text = Reglas.TEXTO
	text.custom_minimum_size = Vector2(0, 400)
	text.add_theme_font_size_override("normal_font_size", 16)
	text.add_theme_font_size_override("bold_font_size", 16)
	box.add_child(text)
	box.add_child(UIKit.button("Entendido", queue_free))
	UITheme.pop_in(box.get_parent())
