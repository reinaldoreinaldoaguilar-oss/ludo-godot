extends Button

func _ready():
	# Nos aseguramos de que el botón siempre esté por encima de TODO
	z_index = 100 
	
	# Conectamos el clic a la fuerza por si el editor no lo agarró
	pressed.connect(_al_presionar_boton)

func _al_presionar_boton():
	print("¡EL BOTÓN FUE PRESIONADO CON ÉXITO!")
	# Cambia esto por tu ruta exacta si está en una carpeta, por ejemplo: "res://Scenes/menu_principal.tscn"
	get_tree().change_scene_to_file("res://menu_principal.tscn")
