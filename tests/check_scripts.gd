extends Node
## Carga todos los scripts y escenas del proyecto para detectar errores de
## compilación. Ejecutar: godot --headless res://tests/check_scripts.tscn

var errors := 0

func _ready() -> void:
	for path in find_files("res://", ["gd", "tscn"]):
		var res = load(path)
		if res == null or (res is GDScript and not res.can_instantiate()):
			errors += 1
			print("  FAIL ", path)
	print("== Revisión de scripts y escenas: %d errores ==" % errors)
	get_tree().quit(1 if errors > 0 else 0)

func find_files(dir: String, exts: Array) -> Array[String]:
	var result: Array[String] = []
	for f in DirAccess.get_files_at(dir):
		if f.get_extension() in exts:
			result.append(dir.path_join(f))
	for d in DirAccess.get_directories_at(dir):
		if not d.begins_with("."):
			result.append_array(find_files(dir.path_join(d), exts))
	return result
