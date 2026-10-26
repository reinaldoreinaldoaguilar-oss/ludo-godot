class_name Effects
extends RefCounted
## Efectos visuales reutilizables: explosiones de partículas y confeti.

static func _circle_texture() -> Texture2D:
	var grad := Gradient.new()
	grad.set_color(0, Color.WHITE)
	grad.set_color(1, Color(1, 1, 1, 0))
	var tex := GradientTexture2D.new()
	tex.gradient = grad
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(0.5, 0.0)
	tex.width = 64
	tex.height = 64
	return tex

## Explosión de partículas de un color en una posición global (mundo 2D).
static func burst(parent: Node, at: Vector2, color: Color, amount: int = 40, speed: float = 700.0) -> void:
	var p := CPUParticles2D.new()
	p.texture = _circle_texture()
	p.one_shot = true
	p.explosiveness = 0.95
	p.amount = amount
	p.lifetime = 0.9
	p.direction = Vector2.UP
	p.spread = 180.0
	p.gravity = Vector2(0, 900)
	p.initial_velocity_min = speed * 0.4
	p.initial_velocity_max = speed
	p.scale_amount_min = 0.4
	p.scale_amount_max = 1.2
	p.color = color
	var ramp := Gradient.new()
	ramp.set_color(0, Color.WHITE)
	ramp.set_color(1, Color(1, 1, 1, 0))
	p.color_ramp = ramp
	p.z_index = 50
	parent.add_child(p)
	p.global_position = at
	p.emitting = true
	p.finished.connect(p.queue_free)

## Confeti de colores sobre la interfaz (posición en pantalla).
static func confetti(parent: Control) -> void:
	var size := parent.get_viewport_rect().size
	for color in GameManager.COLOR_VALUES.values():
		var p := CPUParticles2D.new()
		p.amount = 60
		p.lifetime = 3.5
		p.one_shot = true
		p.explosiveness = 0.2
		p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		p.emission_rect_extents = Vector2(size.x / 2, 10)
		p.position = Vector2(size.x / 2, -20)
		p.direction = Vector2.DOWN
		p.spread = 25.0
		p.gravity = Vector2(0, 160)
		p.initial_velocity_min = 80
		p.initial_velocity_max = 220
		p.angular_velocity_min = -360
		p.angular_velocity_max = 360
		p.scale_amount_min = 6
		p.scale_amount_max = 10
		p.color = color
		parent.add_child(p)
		p.emitting = true
		p.finished.connect(p.queue_free)
