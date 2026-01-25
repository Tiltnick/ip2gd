extends Button
class_name QuestEntry

@onready var name_label: Label = $MarginContainer/HBoxContainer/Label
@onready var new_icon: TextureRect = $MarginContainer/HBoxContainer/TextureRect

var quest_id: String
var quest_data: Dictionary

signal quest_selected(quest_data)

func setup(id: String, data: Dictionary, _is_new := true, completed := false):
	quest_id = id
	quest_data = data
	name_label.text = data["title"]
	disabled = false
	modulate = Color(0.6, 0.6, 0.6) if completed else Color.WHITE
	new_icon.visible = data.get("is_new", false) and not completed

func _pressed():
	if quest_data.get("is_new", false):
		quest_data["is_new"] = false
		GameState.quest_state[quest_id]["is_new"] = false
		new_icon.visible = false
	emit_signal("quest_selected", quest_data)


func mark_as_seen():
	new_icon.visible = false
