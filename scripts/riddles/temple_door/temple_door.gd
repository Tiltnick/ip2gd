extends Interactable

func _ready() -> void:
	super._ready()

func interact():
	SfxPlayer.ui_click_sound()
	open_dialogue()
	
func open_dialogue():
	if GameState.picked_items.has("fire_mush") and GameState.picked_items.has("water_mush"):
		DialogManager.start_dialog("res://dialog/innerMonologue/temple_door_riddle_solved.json")
		await DialogManager.dialog_finished
		hotbarglobal.remove_item("water_mush")
		hotbarglobal.remove_item("fire_mush")
		GameState.puzzle_state["temple_door_open"] = true
		SfxPlayer.stone_grinding()
		$anim.play("open")
		await SfxPlayer.finished
		SfxPlayer.puzzle_solved()
		
		await $anim.animation_finished
		await SfxPlayer.finished
		TransitionAreaFade.transition()
		await TransitionAreaFade.transition_finished
		QuestManager.complete_quest("quest_11")
		#GameState.puzzle_state.set("temple_door_open")
		get_tree().change_scene_to_file("res://scenes/maps/Outside_4/temple.tscn")
		return
		
	elif GameState.picked_items.has("fire_mush") or GameState.picked_items.has("water_mush"):
		DialogManager.start_dialog("res://dialog/innerMonologue/missing_items/missing_water_mush.json")
		await DialogManager.dialog_finished
		QuestManager.add_quest("quest_11")
		return
	
	else: #GameState.picked_items.has("fire_mush") or GameState.picked_items.has("water_mush"):
		DialogManager.start_dialog("res://dialog/spaceship/door_locked_after_riddle.json")
