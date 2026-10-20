extends Button

func _pressed():
	# Cierra el tablero y carga el menú principal de nuevo
	get_tree().change_scene_to_file("res://menu_principal.tscn")
