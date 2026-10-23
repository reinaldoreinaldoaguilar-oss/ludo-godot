class_name Reglas
extends RefCounted
## Texto de las reglas, compartido por el menú principal y el menú de pausa.

const TEXTO := """[b]Objetivo[/b]
Lleva tus 4 fichas desde tu base hasta la meta del centro antes que los demás.

[b]Turno[/b]
• Toca el dado (o pulsa Espacio). Con un [b]6[/b] puedes sacar una ficha de la base.
• Si todas tus fichas están en la base tienes [b]3 intentos[/b] para sacar el 6.
• Un 6 da [b]turno extra[/b]; pero [b]tres seises seguidos[/b] hacen perder el turno.

[b]Capturas y casillas seguras[/b]
• Si caes donde hay una ficha rival, la capturas y vuelve a su base. Ganas turno extra.
• Las [b]estrellas[/b] y las casillas de salida son seguras: ahí nadie captura.

[b]Llegar a la meta[/b]
• Para entrar a la meta necesitas el número [b]exacto[/b]. Llegar da turno extra.

[b]Trivia[/b]
• Al sacar un 6 respondes una pregunta: si fallas, pierdes ese 6.
• Al caer en una estrella también: si fallas, tu ficha regresa.
• Tienes [b]15 segundos[/b]. Cada acierto suma los puntos de la pregunta.

[b]Fin de la partida[/b]
• [b]Rápida:[/b] gana el primero en meter sus 4 fichas.
• [b]Completa:[/b] se juega hasta definir todas las posiciones."""
