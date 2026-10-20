extends Control

# Esta señal le avisará al Ludo si el jugador acertó o falló
signal respondido(es_correcta: bool) 

@onready var texto_pregunta = $Panel/TextoPregunta
@onready var boton0 = $Panel/VBoxContainer/Button
@onready var boton1 = $Panel/VBoxContainer/Button2
@onready var boton2 = $Panel/VBoxContainer/Button3
@onready var boton3 = $Panel/VBoxContainer/Button4

var indice_correcto = 0 # Aquí guardaremos cuál botón tiene la respuesta ganadora

func _ready():
	randomize() # <--- BARAMAMOS LA SEMILLA AQUÍ PARA QUE SEA ALEATORIO
	
	# Mete la ventana al grupo "Trivia" automáticamente al empezar
	add_to_group("Trivia")

	# Conectamos los clics de los botones a nuestra función de evaluación
	boton0.pressed.connect(func(): evaluar_respuesta(0))
	boton1.pressed.connect(func(): evaluar_respuesta(1))
	boton2.pressed.connect(func(): evaluar_respuesta(2))
	boton3.pressed.connect(func(): evaluar_respuesta(3))
	
func cargar_pregunta(categoria: String):
	# Agarramos todo el arreglo de la categoría y elegimos uno al azar
	var datos = BasePreguntas.trivia[categoria].pick_random() 

	texto_pregunta.text = datos["pregunta"]
	boton0.text = datos["opciones"][0]
	boton1.text = datos["opciones"][1]
	boton2.text = datos["opciones"][2]
	boton3.text = datos["opciones"][3]
	
	# Guardamos el número de la opción correcta desde tu base de datos
	indice_correcto = datos["correcta"] 

func evaluar_respuesta(boton_presionado: int):
	if boton_presionado == indice_correcto:
		print("¡Respuesta Correcta!")
		respondido.emit(true)
	else:
		print("Respuesta Incorrecta...")
		respondido.emit(false)
	
	# Después de responder, ocultamos la ventana
	hide()
