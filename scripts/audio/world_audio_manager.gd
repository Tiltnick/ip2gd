extends Node2D

# Wie laut darf das Spiel maximal sein 
@export var MAX_VOLUME_DB := -6.0
@export var MIN_VOLUME_DB := -80.0
@onready var bgm_musicplayer: AudioStreamPlayer = $bgm_musicplayer
@onready var sfx_musicplayer: AudioStreamPlayer = $sfx_musicplayer

func _ready():
	bgm_musicplayer.bus = "Music"
	sfx_musicplayer.bus = "SFX"
	
func play_bgm(stream: AudioStreamInteractive):
	bgm_musicplayer.stream = stream
	bgm_musicplayer.play()

func play_sfx(stream: AudioStream):
	sfx_musicplayer.stream = stream
	sfx_musicplayer.play()


func _on_music_slider_value_changed(value):
	WorldAudioManager.set_music_volume(value)
	
func set_music_volume(percent: float):
	percent = clamp(percent, 0, 100)
	var db = lerp(MIN_VOLUME_DB, MAX_VOLUME_DB, percent / 100.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), db)
	
func set_sound_volume(percent: float):
	percent = clamp(percent, 0, 100)
	var db = lerp(MIN_VOLUME_DB, MAX_VOLUME_DB, percent / 100.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), db)
