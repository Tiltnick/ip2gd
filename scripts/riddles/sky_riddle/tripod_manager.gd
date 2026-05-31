extends Node

const FIRST_PREFIX := "tripod_first_interact_"
const ALL_FLAG := "all_tripods_interacted"

const TRIPOD_IDS := ["tripod_1", "tripod_2", "tripod_3"]


func mark_interacted(tripod_id: String) -> void:
	GameState.unlock_progress_key("telescope_hint_unlocked")

	var flag := FIRST_PREFIX + tripod_id
	
	if not bool(GameState.puzzle_state.get(flag, false)):
		GameState.puzzle_state[flag] = true
		_update_all_flag_if_ready()

#func mark_interacted(tripod_id: String) -> void:
	#var flag := FIRST_PREFIX + tripod_id
	#if not bool(GameState.puzzle_state.get(flag, false)):
		#GameState.puzzle_state[flag] = true
		#GameState.unlock_progress_key("telescope_hint_unlocked")
		#_update_all_flag_if_ready()

func has_interacted(tripod_id: String) -> bool:
	return bool(GameState.puzzle_state.get(FIRST_PREFIX + tripod_id, false))

func all_interacted() -> bool:
	if bool(GameState.puzzle_state.get(ALL_FLAG, false)):
		return true

	for id in TRIPOD_IDS:
		if not has_interacted(id):
			return false
	return true

func _update_all_flag_if_ready() -> void:
	if not bool(GameState.puzzle_state.get(ALL_FLAG, false)) and all_interacted():
		GameState.puzzle_state[ALL_FLAG] = true
		print("TripodManager: Alle Tripods wurden mindestens einmal benutzt.")

#func reset_all() -> void:
	#for id in TRIPOD_IDS:
		#GameState.puzzle_state.erase(FIRST_PREFIX + id)
	#GameState.puzzle_state.erase(ALL_FLAG)
