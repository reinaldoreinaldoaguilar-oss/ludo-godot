extends Node

# Diccionario principal con categorías
var trivia = {
	"futbol": [
		{
			"pregunta": "¿Qué equipo ha ganado más Champions League en la historia?",
			"opciones": ["AC Milan", "FC Barcelona", "Real Madrid", "Bayern Múnich"],
			"correcta": 2,
			"bonus": 3
		},
		{
			"pregunta": "¿Quién ganó el Mundial de la FIFA en 2022?",
			"opciones": ["Francia", "Croacia", "Argentina", "Brasil"],
			"correcta": 2,
			"bonus": 2
		},
		{
			"pregunta": "¿Quién es el máximo goleador histórico de la selección de Venezuela (La Vinotinto)?",
			"opciones": ["Juan Arango", "Salomón Rondón", "Josef Martínez", "Tomás Rincón"],
			"correcta": 1,
			"bonus": 3
		},
		{
			"pregunta": "¿Qué selección ha ganado más Copas del Mundo en la historia?",
			"opciones": ["Alemania", "Italia", "Argentina", "Brasil"],
			"correcta": 3,
			"bonus": 3
		},
		{
			"pregunta": "¿Cuánto dura un partido de fútbol reglamentario (sin tiempo extra)?",
			"opciones": ["80 minutos", "90 minutos", "100 minutos", "120 minutos"],
			"correcta": 1,
			"bonus": 2
		},
		{
			"pregunta": "¿Qué jugador tiene el récord de más Balones de Oro ganados?",
			"opciones": ["Cristiano Ronaldo", "Johan Cruyff", "Lionel Messi", "Diego Maradona"],
			"correcta": 2,
			"bonus": 3
		},
		{
			"pregunta": "¿En qué país se celebró el Mundial de Fútbol de 2010, ganado por España?",
			"opciones": ["Alemania", "Sudáfrica", "Brasil", "Rusia"],
			"correcta": 1,
			"bonus": 2
		},
		{
			"pregunta": "¿Cómo se llama el estadio oficial del FC Barcelona?",
			"opciones": ["Santiago Bernabéu", "San Siro", "Anfield", "Camp Nou"],
			"correcta": 3,
			"bonus": 2
		},
		{
			"pregunta": "¿Qué país ganó la primera Copa del Mundo en 1930?",
			"opciones": ["Uruguay", "Brasil", "Italia", "Inglaterra"],
			"correcta": 0,
			"bonus": 4
		},
		{
			"pregunta": "¿Qué jugador es conocido como 'El Rey' (O Rei) del fútbol?",
			"opciones": ["Diego Maradona", "Pelé", "Ronaldo Nazário", "Alfredo Di Stéfano"],
			"correcta": 1,
			"bonus": 2
		}
	],
	"estructuras": [
		{
			"pregunta": "¿Qué es una Pila (Stack)?",
			"opciones": ["Una estructura LIFO (Último en entrar, primero en salir)", "Una estructura FIFO (Primero en entrar, primero en salir)", "Un arreglo de tamaño fijo", "Un tipo de árbol con 3 hijos"],
			"correcta": 0,
			"bonus": 2
		},
		{
			"pregunta": "¿Qué es una Cola (Queue)?",
			"opciones": ["Un nodo sin punteros", "Una estructura FIFO (Primero en entrar, primero en salir)", "Una estructura LIFO (Último en entrar, primero en salir)", "Una lista circular doble"],
			"correcta": 1,
			"bonus": 2
		},
		{
			"pregunta": "¿Qué diferencia una lista enlazada de un arreglo estático?",
			"opciones": ["El arreglo no puede tener números", "La lista no ocupa memoria", "La lista crece dinámicamente; el arreglo tiene tamaño fijo", "Son exactamente lo mismo"],
			"correcta": 2,
			"bonus": 3
		},
		{
			"pregunta": "En una Lista Enlazada Simple, ¿qué guarda cada nodo además del dato?",
			"opciones": ["Un puntero al nodo anterior", "Un arreglo de números", "El tamaño de la lista", "Un puntero al siguiente nodo"],
			"correcta": 3,
			"bonus": 3
		},
		{
			"pregunta": "¿Qué es una lista doblemente enlazada?",
			"opciones": ["Tiene referencias al nodo anterior y al siguiente", "Tiene dos datos por nodo", "Es una lista que pesa el doble en memoria", "Una lista que solo va hacia atrás"],
			"correcta": 0,
			"bonus": 4
		},
		{
			"pregunta": "¿Qué es un Árbol Binario?",
			"opciones": ["Una lista que se divide en 4", "Una estructura donde cada nodo tiene máximo dos hijos", "Un arreglo ordenado de mayor a menor", "Un nodo sin datos"],
			"correcta": 1,
			"bonus": 4
		},
		{
			"pregunta": "¿Qué sucede en un 'Stack Overflow' (Desbordamiento de Pila)?",
			"opciones": ["El programa se queda sin memoria en la pila de llamadas", "La lista enlazada pierde sus datos", "El disco duro se llena por completo", "El procesador se apaga"],
			"correcta": 0,
			"bonus": 3
		},
		{
			"pregunta": "¿Qué caracteriza a una Lista Circular?",
			"opciones": ["Solo almacena variables tipo float", "El último nodo apunta de nuevo al primer nodo", "No usa punteros de memoria", "Los nodos se borran al leerlos"],
			"correcta": 1,
			"bonus": 3
		},
		{
			"pregunta": "¿Qué son los Vértices y las Aristas en Estructuras de Datos?",
			"opciones": ["Componentes de un Arreglo", "Componentes de una Pila", "Componentes de un Grafo", "Variables de un bucle For"],
			"correcta": 2,
			"bonus": 4
		},
		{
			"pregunta": "¿Qué es un Árbol AVL?",
			"opciones": ["Un árbol que solo guarda letras", "Un árbol de búsqueda binaria autobalanceado", "Una lista enlazada desordenada", "Un árbol sin nodo raíz"],
			"correcta": 1,
			"bonus": 4
		},
		{
			"pregunta": "En programación, ¿qué es un Puntero?",
			"opciones": ["Una variable que guarda la dirección de memoria de otra variable", "Un tipo de dato para texto", "Una función que retorna enteros", "El cursor del ratón"],
			"correcta": 0,
			"bonus": 2
		},
		{
			"pregunta": "¿Para qué sirve una Tabla Hash (Hash Table)?",
			"opciones": ["Para comprimir archivos", "Para dibujar gráficos en 3D", "Para mapear claves a valores y buscar datos rápidamente", "Para compilar código C++"],
			"correcta": 2,
			"bonus": 4
		},
		{
			"pregunta": "¿Qué estructura de datos usa la recursividad por debajo en el sistema?",
			"opciones": ["Una Cola (Queue)", "Una Pila (Stack / Call Stack)", "Una Tabla Hash", "Un Grafo"],
			"correcta": 1,
			"bonus": 3
		},
		{
			"pregunta": "¿Qué es una Cola de Prioridad (Priority Queue)?",
			"opciones": ["Una cola donde el elemento con mayor prioridad sale primero", "Una cola que cobra por entrar", "Una cola FIFO estricta", "Una lista enlazada invertida"],
			"correcta": 0,
			"bonus": 4
		}
	],
	"cultura": [
		{
			"pregunta": "¿Cuál es el río más largo del mundo?",
			"opciones": ["Río Nilo", "Río Orinoco", "Río Amazonas", "Río Misisipi"],
			"correcta": 2,
			"bonus": 2
		},
		{
			"pregunta": "¿Quién pintó la famosa obra de 'La noche estrellada'?",
			"opciones": ["Vincent van Gogh", "Leonardo da Vinci", "Pablo Picasso", "Michelangelo"],
			"correcta": 0,
			"bonus": 3
		},
		{
			"pregunta": "¿En qué año llegó el hombre a la luna?",
			"opciones": ["1965", "1969", "1971", "1959"],
			"correcta": 1,
			"bonus": 3
		},
		{
			"pregunta": "¿Cuál es el planeta más grande del sistema solar?",
			"opciones": ["Júpiter", "Saturno", "Tierra", "Marte"],
			"correcta": 0,
			"bonus": 2
		},
		{
			"pregunta": "¿Cuántos estados conforman políticamente a Venezuela?",
			"opciones": ["20 estados y el Dto. Capital", "24 estados", "23 estados y el Dto. Capital", "22 estados"],
			"correcta": 2,
			"bonus": 3
		},
		{
			"pregunta": "¿Cuál es el océano más grande del mundo?",
			"opciones": ["Océano Atlántico", "Océano Índico", "Océano Ártico", "Océano Pacífico"],
			"correcta": 3,
			"bonus": 2
		},
		{
			"pregunta": "¿En qué año se libró la Batalla de Carabobo?",
			"opciones": ["1810", "1811", "1821", "1830"],
			"correcta": 2,
			"bonus": 4
		},
		{
			"pregunta": "¿Cuál es la montaña más alta del mundo sobre el nivel del mar?",
			"opciones": ["K2", "Monte Everest", "Aconcagua", "Pico Bolívar"],
			"correcta": 1,
			"bonus": 2
		},
		{
			"pregunta": "¿Quién escribió 'Don Quijote de la Mancha'?",
			"opciones": ["Gabriel García Márquez", "Miguel de Cervantes", "Jorge Luis Borges", "William Shakespeare"],
			"correcta": 1,
			"bonus": 3
		},
		{
			"pregunta": "¿Cuál es el hueso más pequeño del cuerpo humano?",
			"opciones": ["El estribo (en el oído)", "La falange", "El fémur", "El radio"],
			"correcta": 0,
			"bonus": 4
		},
		{
			"pregunta": "¿Qué gas es el más abundante en la atmósfera de la Tierra?",
			"opciones": ["Oxígeno", "Dióxido de Carbono", "Hidrógeno", "Nitrógeno"],
			"correcta": 3,
			"bonus": 4
		},
		{
			"pregunta": "¿Cuál es la capital de Australia?",
			"opciones": ["Sídney", "Melbourne", "Canberra", "Perth"],
			"correcta": 2,
			"bonus": 4
		},
		{
			"pregunta": "¿Quién fue el primer presidente de Venezuela?",
			"opciones": ["Simón Bolívar", "José Antonio Páez", "Cristóbal Mendoza", "Antonio Guzmán Blanco"],
			"correcta": 2,
			"bonus": 4
		},
		{
			"pregunta": "¿Cuál es el símbolo químico de la Plata?",
			"opciones": ["Pt", "Ag", "Au", "Pl"],
			"correcta": 1,
			"bonus": 3
		},
		{
			"pregunta": "¿Cuál es el país más grande del mundo por superficie?",
			"opciones": ["Canadá", "China", "Estados Unidos", "Rusia"],
			"correcta": 3,
			"bonus": 2
		},
		{
			"pregunta": "¿En qué continente se encuentra el desierto del Sahara?",
			"opciones": ["Asia", "África", "América", "Oceanía"],
			"correcta": 1,
			"bonus": 2
		},
		{
			"pregunta": "¿Qué instrumento musical tiene 88 teclas?",
			"opciones": ["El acordeón", "La guitarra", "El piano", "El órgano"],
			"correcta": 2,
			"bonus": 2
		}
	]
}
