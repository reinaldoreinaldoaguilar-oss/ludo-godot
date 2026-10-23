extends Node
## Autoload: efectos de sonido y música, con volúmenes guardados en user://ajustes.cfg.

const SETTINGS_PATH := "user://ajustes.cfg"
const SOUNDS := {
	"dice_roll": "res://Arts/Audio/dice_roll.wav",
	"dice_land": "res://Arts/Audio/dice_land.wav",
	"step": "res://Arts/Audio/step.wav",
	"select": "res://Arts/Audio/select.wav",
	"capture": "res://Arts/Audio/capture.wav",
	"home": "res://Arts/Audio/home.wav",
	"correct": "res://Arts/Audio/correct.wav",
	"wrong": "res://Arts/Audio/wrong.wav",
	"click": "res://Arts/Audio/click.wav",
	"turn": "res://Arts/Audio/turn.wav",
	"extra": "res://Arts/Audio/extra.wav",
	"win": "res://Arts/Audio/win.wav",
}
const MUSIC := "res://Arts/Audio/music_loop.wav"
const POOL_SIZE := 8

var sfx_volume: float = 0.8
var music_volume: float = 0.5
var streams: Dictionary = {}
var pool: Array[AudioStreamPlayer] = []
var music_player: AudioStreamPlayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_settings()
	for key in SOUNDS:
		streams[key] = load(SOUNDS[key])
	for i in POOL_SIZE:
		var p := AudioStreamPlayer.new()
		add_child(p)
		pool.append(p)
	music_player = AudioStreamPlayer.new()
	var music: AudioStreamWAV = load(MUSIC)
	music.loop_mode = AudioStreamWAV.LOOP_FORWARD
	music.loop_end = int(music.get_length() * music.mix_rate)
	music_player.stream = music
	add_child(music_player)
	apply_volumes()

func play(sound: String, pitch_variation: float = 0.0) -> void:
	if not streams.has(sound) or sfx_volume <= 0.0:
		return
	for p in pool:
		if not p.playing:
			p.stream = streams[sound]
			p.pitch_scale = 1.0 + randf_range(-pitch_variation, pitch_variation)
			p.play()
			return

func play_music() -> void:
	if not music_player.playing:
		music_player.play()

func stop_music() -> void:
	music_player.stop()

func set_sfx_volume(value: float) -> void:
	sfx_volume = clampf(value, 0.0, 1.0)
	apply_volumes()
	save_settings()

func set_music_volume(value: float) -> void:
	music_volume = clampf(value, 0.0, 1.0)
	apply_volumes()
	save_settings()

func apply_volumes() -> void:
	for p in pool:
		p.volume_db = linear_to_db(maxf(sfx_volume, 0.0001))
	if music_player:
		music_player.volume_db = linear_to_db(maxf(music_volume * 0.6, 0.0001))
		music_player.stream_paused = music_volume <= 0.0

func load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS_PATH) == OK:
		sfx_volume = cfg.get_value("audio", "sfx", sfx_volume)
		music_volume = cfg.get_value("audio", "musica", music_volume)

func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.load(SETTINGS_PATH)
	cfg.set_value("audio", "sfx", sfx_volume)
	cfg.set_value("audio", "musica", music_volume)
	cfg.save(SETTINGS_PATH)
