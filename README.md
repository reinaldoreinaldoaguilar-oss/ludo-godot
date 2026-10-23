# Ludo Trivia — Godot 4

Ludo clásico para 2 a 4 jugadores (humanos o bots) con **trivia integrada**:
al sacar un 6 o caer en una estrella hay que responder una pregunta de fútbol,
estructuras de datos o cultura general.

Hecho con **Godot 4.7** y **GDScript**.

## Cómo jugar

1. Abre el proyecto en Godot 4.7 y pulsa *Ejecutar* (F5).
2. **Jugar** → elige número de jugadores, nombres, quién es bot, dificultad,
   modo de victoria y si la trivia está activada.
3. Toca el dado (o pulsa **Espacio**) y luego la ficha resaltada que quieras mover.
4. **Esc** abre la pausa (reglas, ajustes, reiniciar, salir).

Las reglas completas están en el menú **Reglas** dentro del juego.

## Funciones

- Reglas completas: salida con 6 (3 intentos si no hay fichas en juego), turno extra
  con 6, captura o llegada a meta, tres seises seguidos pierden el turno, casillas
  seguras y llegada exacta a la meta.
- Bots con 3 niveles: **Fácil** (al azar), **Normal** (prioriza capturar y avanzar),
  **Difícil** (además evita casillas amenazadas y huye del peligro).
- Trivia con temporizador de 15 s, opciones barajadas y puntos por acierto.
- **Gestor de preguntas**: ver el banco y agregar/eliminar preguntas propias.
- Partida rápida (gana el primero) o completa (ranking de todos).
- Animaciones (saltos, capturas, dado), partículas, confeti, sonido y música.
- Pantalla final con estadísticas por jugador e historial de partidas guardado.
- Ajustes guardados: volumen de efectos y música, velocidad de bots, pantalla completa.

## Estructura del proyecto

```
res://
├── Arts/            Texturas, animaciones, fuente (Nunito) y audio
├── Data/            preguntas.json (banco de preguntas de la trivia)
├── Levels/          Level_MainGamePlay.tscn (partida)
├── Scenes/          Menú, HUD, trivia, fichas y escenas raíz (Roots)
├── Scripts/         Lógica del juego
└── tests/           Pruebas automáticas y herramientas
```

### Arquitectura (Scripts/)

| Script | Responsabilidad |
|---|---|
| `GameManager.gd` (autoload) | Estados, configuración de la partida, ajustes e historial |
| `LudoRules.gd` | **Reglas puras** (movimientos, capturas, turnos, IA). Sin nodos: se prueban solas |
| `BoardManager.gd` | Máquina de estados del turno: dado → elegir ficha → mover → capturas → siguiente |
| `Piece.gd`, `PlayerPieceGroup.gd`, `PiecesManager.gd` | Fichas y grupos por color |
| `WayPoint.gd`, `WayPointManager.gd` | Casillas y caminos de cada color |
| `Dice.gd` | Dado animado (no conoce las reglas) |
| `HUD.gd` | Interfaz de la partida, pausa y pantalla final |
| `GameFeedback.gd` | Sonidos, partículas y temblor de cámara (solo escucha señales) |
| `ventana_trivial.gd`, `BasePreguntas.gd` (autoload) | Trivia y banco de preguntas |
| `AudioManager.gd` (autoload) | Efectos y música |
| `UITheme.gd`, `UIKit.gd`, `PanelAjustes.gd`, `PanelReglas.gd` | Estilo y componentes de interfaz |

La lógica y la presentación están separadas: `BoardManager` emite señales
(`turn_started`, `piece_captured`, `game_over`...) y la interfaz y los efectos
reaccionan a ellas sin modificar el estado del juego.

## Pruebas automáticas

```bash
godot --headless res://tests/test_rules.tscn      # 40 pruebas de reglas, IA y preguntas
godot --headless res://tests/simulation.tscn      # 4 partidas completas simuladas
godot --headless res://tests/check_scripts.tscn   # compila todos los scripts y escenas
```

## Exportar

Al exportar, agrega `*.json` en *Exportar → Recursos → Filtros para exportar
archivos que no son recursos*, para incluir `Data/preguntas.json`.

## Créditos y licencias

- Basado en el proyecto open source *Godot Ludo* de **rathod ketan** (licencia MIT, ver `LICENSE`).
- Gráficos del tablero: *Ludo Graphic Design* de **Bharat kumawat** (CC BY 4.0, ver `ASSETS_LICENSE.md`).
- Fuente **Nunito** (SIL Open Font License, ver `Arts/Fonts/Nunito-OFL.txt`).
- Efectos de sonido y música generados para este proyecto.
- Trivia, reglas ampliadas, IA, interfaz y demás mejoras: equipo del proyecto.
