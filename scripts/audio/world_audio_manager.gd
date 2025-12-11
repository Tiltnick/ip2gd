extends Node2D

@export var MAX_VOLUME_DB := -6.0
@export var MIN_VOLUME_DB := -80.0
@onready var bgm_musicplayer: AudioStreamPlayer = $bgm_musicplayer
@onready var sfx_musicplayer: AudioStreamPlayer = $sfx_musicplayer

func _ready():
	bgm_musicplayer.bus = "Music"
	sfx_musicplayer.bus = "SFX"
	#push_warning(GameState.music_setting)
	#if GameState.music_setting != null:
		#set_music_volume(GameState.music_setting)
	#if GameState.sound_setting != null:
		#set_sound_volume(GameState.sound_setting)

func play_bgm(stream: AudioStream):
	bgm_musicplayer.stream = stream
	bgm_musicplayer.play()

func play_sfx(stream: AudioStream):
	sfx_musicplayer.stream = stream
	sfx_musicplayer.play()

func _on_music_slider_value_changed(value):
	WorldAudioManager.set_music_volume(value)

func set_music_volume(percent: float):
	GameState.music_setting = percent
	push_warning(GameState.music_setting)
	percent = clamp(percent, 0, 100)
	var db = lerp(MIN_VOLUME_DB, MAX_VOLUME_DB, percent / 100.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), db)
	SaveSystem.save_game()

func set_sound_volume(percent: float):
	GameState.sound_setting = percent
	percent = clamp(percent, 0, 100)
	var db = lerp(MIN_VOLUME_DB, MAX_VOLUME_DB, percent / 100.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), db)
	SaveSystem.save_game()
	
