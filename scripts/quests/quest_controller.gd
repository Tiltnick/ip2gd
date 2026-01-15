extends Control
class_name QuestController

@onready var current_list = $DisplayLeft/ScrollContainer/VBoxContainer/current_list
@onready var completed_list = $DisplayLeft/ScrollContainer/VBoxContainer/completed_list
@onready var quest_title = $DisplayRight/QuestTitle
@onready var quest_desc = $DisplayRight/QuestDescription
@onready var item_display = $DisplayRight/ItemDisplay
@onready var item_slot = $DisplayRight/ItemDisplay/NeededItems/Slot


@export var quest_entry_scene: PackedScene = load("res://scenes/Menues/QuestMenu/QuestEntry.tscn")

func _ready():
	item_display.visible = false
	#item_slot.texture = null   # Slot ist leer

	QuestManager.quest_added.connect(add_quest)
	QuestManager.quest_completed.connect(complete_quest)
	_rebuild_ui()

func _rebuild_ui():
	QuestManager.quest_added.disconnect(add_quest)

	# Clear old entries
	for c in current_list.get_children():
		c.queue_free()

	for c in completed_list.get_children():
		c.queue_free()

	# Rebuild current quests
	for quest in QuestManager.current_quests.values():
		add_quest(quest)

	# Rebuild completed quests
	for quest in QuestManager.completed_quests.values():
		complete_quest(quest)

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
	quest_title.text = quest["title"]
	quest_desc.text = quest["description"]

	# 👇 ITEM-LOGIK
	if quest.get("needs_item", false):
		_show_item_requirement(quest)
	else:
		item_display.visible = false

	if quest.get("is_new", false):
		quest["is_new"] = false
		GameState.quest_state[quest["id"]]["is_new"] = false
		_update_entry_icon(quest["id"])


func _update_entry_icon(quest_id: String):
	for entry in current_list.get_children():
		if entry.quest_id == quest_id:
			entry.mark_as_seen()
			return

func _show_item_requirement(quest: Dictionary):
	item_display.visible = true
#	item_slot.texture = null

	var icon_path: String = quest.get("icon_path", "")
	if icon_path.is_empty():
		return

	if GameState.picked_items.has(icon_path):
		_fill_item_slot(icon_path, quest)


func _fill_item_slot(icon_path: String, quest: Dictionary):
	if not ResourceLoader.exists(icon_path):
		push_warning("Item icon not found: " + icon_path)
		return

	item_slot.texture = load(icon_path)

	# 🔔 Quest-Update Popup
	PopupManager.popup_update_quest(quest)
