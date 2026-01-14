extends NPC
class_name SamGhostNPC

@export var sam_path_follow: PathFollow2D
@export var start_move_state_name: String = "move"

@onready var state_machine: NPCStateMachine = $stateMachine

func _ready() -> void:
	super._ready()

	# Dialog-Ende -> Sam läuft los
	DialogManager.dialog_finished.connect(_on_dialog_finished)

	# Referenz ins NPC-Basisfeld (damit states wie npc_move drauf zugreifen könnten)
	if sam_path_follow:
		path_follow = sam_path_follow

func _exit_tree() -> void:
	# sauber trennen
	if DialogManager.dialog_finished.is_connected(_on_dialog_finished):
		DialogManager.dialog_finished.disconnect(_on_dialog_finished)

func _on_dialog_finished() -> void:
	# Sam soll NUR nach seinem Dialog loslaufen:
	# wenn Spieler nicht in Range ist, ignorieren
	if not player_inside:
		return

	# Dialog ist vorbei -> Bewegung starten
	if state_machine:
		state_machine.request_transition(start_move_state_name)

	# NPC-Base setzt dialog_active sonst nur beim Verlassen zurück,
	# daher hier freigeben:
	dialog_active = false
