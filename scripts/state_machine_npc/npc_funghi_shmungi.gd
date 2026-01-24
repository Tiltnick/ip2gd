extends NPC

const DIALOG := {
	"Outside3": "res://dialog/mushrooms/funghi_shmunghi.json",
}

func _ready() -> void:
	super._ready()

func get_dialogue():
	return DIALOG
