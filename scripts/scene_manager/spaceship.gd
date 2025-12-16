extends Node2D


func _ready() -> void:
	#WorldAudioManager.play_bgm(load("res://assets/sound/Cozy Tunes (Pro) v1.4/Cozy Tunes (Pro)/Audio/wav/Tracks/Polar Lights.wav"))
	print("Locale:", TranslationServer.get_locale())

	if not GameState.puzzle_state.get("wakeup_done", false):
			GameState.puzzle_state["wakeup_done"] = true
			DialogManager.start_dialog("res://dialog/innerMonologue/wakeup.json")
