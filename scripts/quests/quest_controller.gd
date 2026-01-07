extends Control
class_name QuestController

@onready var current_list = $DisplayLeft/ScrollContainer/VBoxContainer
@onready var completed_list = $DisplayLeft/ScrollContainer2/VBoxContainer
@onready var quest_title = $DisplayRight/QuestTitle
@onready var quest_desc = $DisplayRight/QuestDescription

@export var quest_entry_scene: PackedScene

func _ready():
	QuestManager.quest_added.connect(_on_quest_added)
	QuestManager.quest_completed.connect(_on_quest_completed)

func _on_quest_added(quest):
	var entry = quest_entry_scene.instantiate()
	entry.setup(quest["id"], quest, true, false)
	entry.quest_selected.connect(_show_quest)
	current_list.add_child(entry)

func _on_quest_completed(quest):
	var entry = quest_entry_scene.instantiate()
	entry.setup(quest["id"], quest, false, true)
	completed_list.add_child(entry)

func _show_quest(quest):
	quest_title.text = quest["title"]
	quest_desc.text = quest["description"]
