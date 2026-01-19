extends Control
class_name QuestController

@onready var current_list = $DisplayLeft/ScrollContainer/VBoxContainer/current_list
@onready var completed_list = $DisplayLeft/ScrollContainer/VBoxContainer/completed_list
@onready var quest_title = $DisplayRight/QuestTitle
@onready var quest_desc = $DisplayRight/QuestDescription
@onready var item_display = $DisplayRight/ItemDisplay
@onready var item_box = $DisplayRight/ItemDisplay/HBoxContainer
@onready var spacegram_hint = $DisplayRight/Spacegram_Hint

@export var quest_entry_scene: PackedScene = preload("res://scenes/Menues/QuestMenu/QuestEntry.tscn")
@export var slot_scene: PackedScene = preload("res://scenes/hotbar/slot.tscn")

var selected_quest_id: String = ""

func _ready():
	item_display.visible = false
	spacegram_hint.visible = false

	QuestManager.quest_added.connect(add_quest)
	QuestManager.quest_completed.connect(complete_quest)
	QuestManager.quest_updated.connect(_on_quest_updated)

	_rebuild_ui()


func _rebuild_ui():
	for c in current_list.get_children():
		c.queue_free()
	for c in completed_list.get_children():
		c.queue_free()

	for q in QuestManager.current_quests.values():
		add_quest(q)
	for q in QuestManager.completed_quests.values():
		complete_quest(q)


func add_quest(quest: Dictionary):
	var entry = quest_entry_scene.instantiate()
	current_list.add_child(entry)
	entry.setup(quest["id"], quest, true, false)
	entry.quest_selected.connect(_show_quest)


func complete_quest(quest: Dictionary):
	var entry = quest_entry_scene.instantiate()
	completed_list.add_child(entry)
	entry.setup(quest["id"], quest, false, true)
	entry.quest_selected.connect(_show_quest)


func _show_quest(quest: Dictionary):
	selected_quest_id = quest.get("id", "")

	quest_title.text = quest.get("title", "")
	quest_desc.text = quest.get("description", "")

	_show_item_requirement(quest)
	spacegram_hint.visible = quest.get("spacegram_hint", false)


func _show_item_requirement(quest: Dictionary):
	for c in item_box.get_children():
		c.queue_free()

	var items: Array = quest.get("needs_items", [])
	if items.is_empty():
		item_display.visible = false
		return

	item_display.visible = true

	for item_id in items:
		var slot: HotbarSlot = slot_scene.instantiate()
		item_box.add_child(slot)

		# Slot ist rein visuell → kein Click
		slot.set_click_callback(Callable())

		if GameState.picked_items.has(item_id):
			slot.set_item_icon(item_id)
		else:
			slot.clear_icon()


func _on_quest_updated(quest: Dictionary) -> void:
	_show_quest(quest)

	# optional: links neu zeichnen (New-Icon etc.)
	_rebuild_ui()
