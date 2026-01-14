extends NPC
class_name SamGhostNPC

@export var start_move_state_name: String = "move"

# Flag, damit er wirklich nur nach dem *ersten* Dialog losläuft
const FIRST_DIALOG_DONE_FLAG := "sam_outside5_first_dialog_done"

@onready var state_machine: Node = $stateMachine

var _dialog_was_started_by_me: bool = false
var _is_moving: bool = false


func _ready() -> void:
	super._ready()

	# Dialog-Ende abfangen
	if DialogManager and DialogManager.has_signal("dialog_finished"):
		DialogManager.dialog_finished.connect(_on_dialog_finished)


func _exit_tree() -> void:
	if DialogManager and DialogManager.has_signal("dialog_finished"):
		if DialogManager.dialog_finished.is_connected(_on_dialog_finished):
			DialogManager.dialog_finished.disconnect(_on_dialog_finished)


# WICHTIG:
# Diese Methode muss bei dir aufgerufen werden, wenn der Spieler mit Sam interagiert.
# In vielen NPC-Basen heißt das z.B. "interact()" oder wird über "Press_E_Popup_NPC" getriggert.
# Falls deine Base-Klasse eine andere Methode nutzt: sag mir den Namen, dann passe ich es exakt an.
func interact() -> void:
	# nur wenn Spieler in Range
	if not player_inside:
		return

	_dialog_was_started_by_me = true

	# Dialog starten (deine NPC-Base macht das evtl. schon)
	# Wenn deine NPC-Base bereits den Dialog startet, kannst du die nächste Zeile weglassen.
	if has_method("start_dialog"):
		start_dialog()


func _on_dialog_finished() -> void:
	# Dialog-Ende interessiert uns nur, wenn Sam den Dialog gestartet hat
	if not _dialog_was_started_by_me:
		return
	_dialog_was_started_by_me = false

	# Nur in Outside5 und nur beim ersten Dialog
	var scene_name := get_tree().current_scene.name
	if scene_name != "Outside5":
		return

	if bool(GameState.puzzle_state.get(FIRST_DIALOG_DONE_FLAG, false)):
		return

	# Pfad muss gesetzt sein (Outside5/sam_follow)
	if path_follow == null:
		push_warning("SamGhostNPC: path_follow ist nicht gesetzt (Outside5/sam_follow im Inspector zuweisen).")
		return

	# Flag setzen: ab jetzt war der erste Dialog done
	GameState.puzzle_state[FIRST_DIALOG_DONE_FLAG] = true

	# Bewegung starten
	_start_path()


func _start_path() -> void:
	if _is_moving:
		return
	_is_moving = true

	path_follow.progress = 0.0
	global_position = path_follow.global_position

	_transition_to(start_move_state_name)


func _transition_to(state_name: String) -> void:
	# kompatibel mit deinen verschiedenen StateMachine-Versionen
	if state_machine.has_method("request_transition"):
		state_machine.call("request_transition", state_name)
		return
	if state_machine.has_method("_on_state_transition"):
		state_machine.call("_on_state_transition", state_name)
		return
	if state_machine.has_variable("current_state"):
		var cs = state_machine.get("current_state")
		if cs and cs.has_signal("state_transition"):
			cs.emit_signal("state_transition", state_name)
			return

	push_warning("SamGhostNPC: Keine passende Transition-Methode gefunden.")


func on_path_finished() -> void:
	# Wird vom Move-State gerufen
	_is_moving = false
