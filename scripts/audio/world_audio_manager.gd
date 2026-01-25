extends Node2D

@export var MAX_VOLUME_DB := -6.0
@export var MIN_VOLUME_DB := -80.0


func set_music_volume(percent: float):
	GameState.music_setting = percent
	percent = clamp(percent, 0, 100)
	var db = lerp(MIN_VOLUME_DB, MAX_VOLUME_DB, percent / 100.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), db)
	
	if not get_tree().get_nodes_in_group("player").is_empty():
		SaveSystem.save_game()

func set_sound_volume(percent: float):
	GameState.sound_setting = percent
	percent = clamp(percent, 0, 100)
	var db = lerp(MIN_VOLUME_DB, MAX_VOLUME_DB, percent / 100.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), db)
	
	if not get_tree().get_nodes_in_group("player").is_empty():
		SaveSystem.save_game()
	
