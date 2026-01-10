extends Control
class_name QuestController

@onready var current_list = $DisplayLeft/ScrollContainer/VBoxContainer/current_list
@onready var completed_list = $DisplayLeft/ScrollContainer/VBoxContainer/completed_list
@onready var quest_title = $DisplayRight/QuestTitle
@onready var quest_desc = $DisplayRight/QuestDescription

@export var quest_entry_scene: PackedScene = load("res://scenes/Menues/QuestMenu/QuestEntry.tscn")

func _ready():
	QuestManager.quest_added.connect(_on_quest_added)
	QuestManager.quest_completed.connect(_on_quest_completed)
	_rebuild_ui()

func _rebuild_ui():
	# Clear old entries
	for c in current_list.get_children():
		c.queue_free()

	for c in completed_list.get_children():
		c.queue_free()

	# Rebuild current quests
	for quest in QuestManager.current_quests.values():
		_on_quest_added(quest)

	# Rebuild completed quests
	for quest in QuestManager.completed_quests.values():
		_on_quest_completed(quest)


#func _on_quest_added(quest):
	#var entry = quest_entry_scene.instantiate()
	#entry.setup(quest["id"], quest, true, false)
	#entry.quest_selected.connect(_show_quest)
	#current_list.add_child(entry)

func _on_quest_added(quest: Dictionary):
	var entry = quest_entry_scene.instantiate()
	current_list.add_child(entry)   # ✅ ZUERST in den Tree
	entry.setup(quest["id"], quest, true, false)
	entry.quest_selected.connect(_show_quest)


#func _on_quest_completed(quest):
	#var entry = quest_entry_scene.instantiate()
	#entry.setup(quest["id"], quest, false, true)
	#entry.quest_selected.connect(_show_quest)
	#completed_list.add_child(entry)

func _on_quest_completed(quest: Dictionary):
	var entry = quest_entry_scene.instantiate()
	completed_list.add_child(entry)
	entry.setup(quest["id"], quest, false, true)
	entry.quest_selected.connect(_show_quest)


func _show_quest(quest):
	quest_title.text = quest["title"]
	quest_desc.text = quest["description"]
	print(quest_title.text, quest_desc.text)
