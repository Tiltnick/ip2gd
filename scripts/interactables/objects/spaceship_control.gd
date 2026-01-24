extends Interactable

func interact():
	SfxPlayer.ui_click_sound()
	if GameState.dialog_state.has("res://dialog/dialogueMrBlob/outside_4.json"):
		DialogManager.start_dialog("res://dialog/innerMonologue/spaceship_control_end.json")
		await DialogManager.dialog_finished
		await transition()
		get_tree().change_scene_to_file("res://scenes/Cutscenes/ending_scene.tscn")
		return
	else:
		DialogManager.start_dialog("res://dialog/innerMonologue/spaceship_control.json")
		return

func transition():
	TransitionAreaFade.transition()
	await TransitionAreaFade.transition_finished
