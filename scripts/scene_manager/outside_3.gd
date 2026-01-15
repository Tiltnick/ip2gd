extends Node2D

func _ready() -> void:
	BgmPlayer.bgm_outside3()
	if not GameState.puzzle_state.get("outside3_monologue_done", false):
		GameState.puzzle_state["outside3_monologue_done"] = true
		DialogManager.start_dialog("res://dialog/mushrooms/outside_3_begin.json")
	var lang = TranslationServer.get_locale().substr(0, 2)
	if lang == "en":
		PopupManager.popup_spacegram_en()
	elif lang == "de":
		PopupManager.popup_spacegram_de()
	if not GameState.map_state.get("outside3_map", false):
		GameState.map_state["outside3_map"] = true

func configure_camera(cam: Camera2D) -> void:
	# Cam Limits
	cam.limit_left = 35
	cam.limit_right = 800
	cam.limit_top = -735
	cam.limit_bottom = 300
	
