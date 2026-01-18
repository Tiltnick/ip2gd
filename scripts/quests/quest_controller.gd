#extends Control
#class_name QuestController
#
#@onready var current_list = $DisplayLeft/ScrollContainer/VBoxContainer/current_list
#@onready var completed_list = $DisplayLeft/ScrollContainer/VBoxContainer/completed_list
#@onready var quest_title = $DisplayRight/QuestTitle
#@onready var quest_desc = $DisplayRight/QuestDescription
#@onready var item_display = $DisplayRight/ItemDisplay
#@onready var item_slot = $DisplayRight/ItemDisplay/NeededItems/Slot
#@onready var spacegram_hint = $DisplayRight/Spacegram_Hint
#
#
#@export var quest_entry_scene: PackedScene = load("res://scenes/Menues/QuestMenu/QuestEntry.tscn")
#
#func _ready():
	#item_display.visible = false
	##item_slot.texture = null   # Slot ist leer
#
	#QuestManager.quest_added.connect(add_quest)
	#QuestManager.quest_completed.connect(complete_quest)
	#_rebuild_ui()
#
#func _rebuild_ui():
	#QuestManager.quest_added.disconnect(add_quest)
#
	## Clear old entries
	#for c in current_list.get_children():
		#c.queue_free()
#
	#for c in completed_list.get_children():
		#c.queue_free()
#
	## Rebuild current quests
	#for quest in QuestManager.current_quests.values():
		#add_quest(quest)
#
	## Rebuild completed quests
	#for quest in QuestManager.completed_quests.values():
		#complete_quest(quest)
#
#func add_quest(quest: Dictionary):
	#var entry = quest_entry_scene.instantiate()
	#current_list.add_child(entry)
	#entry.setup(quest["id"], quest, true, false)
	#entry.quest_selected.connect(_show_quest)
#
#func complete_quest(quest: Dictionary):
	#var entry = quest_entry_scene.instantiate()
	#completed_list.add_child(entry)
	#entry.setup(quest["id"], quest, false, true)
	#entry.quest_selected.connect(_show_quest)
#
#func _show_quest(quest: Dictionary):
	#quest_title.text = quest["title"]
	#quest_desc.text = quest["description"]
#
	## 👇 ITEM-LOGIK
	#if quest.get("needs_item", false):
		#_show_item_requirement(quest)
	#else:
		#item_display.visible = false
#
	#if quest.get("is_new", false):
		#quest["is_new"] = false
		#GameState.quest_state[quest["id"]]["is_new"] = false
		#_update_entry_icon(quest["id"])
#
#
#func _update_entry_icon(quest_id: String):
	#for entry in current_list.get_children():
		#if entry.quest_id == quest_id:
			#entry.mark_as_seen()
			#return
#
#func _show_item_requirement(quest: Dictionary):
	#item_display.visible = true
##	item_slot.texture = null
#
	#var icon_path: String = quest.get("icon_path", "")
	#if icon_path.is_empty():
		#return
#
	#if GameState.picked_items.has(icon_path):
		#_fill_item_slot(icon_path, quest)
#
#
#func _fill_item_slot(icon_path: String, quest: Dictionary):
	#if not ResourceLoader.exists(icon_path):
		#push_warning("Item icon not found: " + icon_path)
		#return
#
	#item_slot.texture = load(icon_path)
#
	## 🔔 Quest-Update Popup
	#PopupManager.popup_update_quest(quest)
#
#func show_spacegram_hint():
	#spacegram_hint.visible = true

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

func _ready():
	if quest_entry_scene == null:
		push_error("QuestController: quest_entry_scene is NULL. Set it in Inspector or preload it.")
		return

	if slot_scene == null:
		push_error("QuestController: slot_scene is NULL. Check path preload.")
		return

	item_display.visible = false
	spacegram_hint.visible = false

	QuestManager.quest_added.connect(add_quest)
	QuestManager.quest_completed.connect(complete_quest)
	QuestManager.quest_item_progressed.connect(_on_quest_item_progressed)

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


func _on_quest_item_progressed(quest: Dictionary, item_id: String) -> void:
	PopupManager.popup_update_quest(quest)  # oder eine spezielle Popup-Funktion
	
	
func update_quest(quest: Dictionary) -> void:
	var entry = quest_entry_scene.instantiate()
	completed_list.add_child(entry)
	entry.setup(quest["id"], quest, false, true)
	entry.quest_updated.connect(_show_quest)
	PopupManager.popup_update_quest(quest)


func complete_quest(quest: Dictionary):
	var entry = quest_entry_scene.instantiate()
	completed_list.add_child(entry)
	entry.setup(quest["id"], quest, false, true)
	entry.quest_selected.connect(_show_quest)


func _show_quest(quest: Dictionary):
	quest_title.text = quest["title"]
	quest_desc.text = quest["description"]

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
