class_name PanelAjustes
extends ColorRect
## Ventana de ajustes (volumen, velocidad de bots, pantalla completa).
## Se usa desde el menú principal y desde la pausa: PanelAjustes.abrir(padre)

signal cerrado

static func abrir(parent: Control) -> PanelAjustes:
	var p := PanelAjustes.new()
	parent.add_child(p)
	return p

func _ready() -> void:
	color = Color(0, 0, 0, 0.6)
	set_anchors_preset(Control.PRESET_FULL_RECT)
	process_mode = Node.PROCESS_MODE_ALWAYS
	var box := UIKit.centered_box(self, 440, 14)
	box.add_child(UIKit.title("Ajustes"))
	box.add_child(slider_row("Efectos", AudioManager.sfx_volume, func(v):
		AudioManager.set_sfx_volume(v)
		AudioManager.play("click")))
	box.add_child(slider_row("Música", AudioManager.music_volume, AudioManager.set_music_volume))
	box.add_child(UIKit.row([
		UIKit.expand(UIKit.label("Velocidad de los bots", 17)),
		UIKit.option(["Lenta", "Normal", "Rápida"], GameManager.velocidad_bots, func(i): GameManager.set_ajuste("velocidad_bots", i)),
	]))
	var fs := CheckButton.new()
	fs.text = "Pantalla completa"
	fs.add_theme_font_size_override("font_size", 17)
	fs.button_pressed = DisplayServer.window_get_mode() >= DisplayServer.WINDOW_MODE_FULLSCREEN
	fs.toggled.connect(func(on):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if on else DisplayServer.WINDOW_MODE_WINDOWED))
	box.add_child(fs)
	box.add_child(UIKit.button("Listo", cerrar))
	UITheme.pop_in(box.get_parent())

func slider_row(text: String, value: float, on_change: Callable) -> HBoxContainer:
	var s := HSlider.new()
	s.min_value = 0.0
	s.max_value = 1.0
	s.step = 0.05
	s.value = value
	s.custom_minimum_size = Vector2(200, 30)
	s.value_changed.connect(on_change)
	return UIKit.row([UIKit.expand(UIKit.label(text, 17)), s])

func cerrar() -> void:
	cerrado.emit()
	queue_free()
