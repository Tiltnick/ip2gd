extends Node

var QUEST_ICON := preload("res://assets/sprites/selfmade/Quest_Icon.png")

var popup_scene := preload("res://scenes/UI/Popup.tscn")
var quest_popup_scene := preload("res://scenes/UI/Quest_Popup.tscn")
var popup: UIPopup
var quest_popup: UIPopup

var SPACEGRAM_URL := "https://www.instagram.com/oris.is.here/"

# --- Queue Logik ---
var _queue: Array[Dictionary] = []
var _showing := false

func _ready():
	QuestManager.quest_added.connect(popup_add_quest)
	QuestManager.quest_completed.connect(popup_complete_quest)

	popup = popup_scene.instantiate()
	quest_popup = quest_popup_scene.instantiate()

	# In CanvasLayer packen
	var ui := CanvasLayer.new()
	get_tree().root.add_child.call_deferred(ui)
	ui.add_child(popup)
	ui.add_child(quest_popup)

	popup.visible = false
	quest_popup.visible = false


func _enqueue(target_popup: UIPopup, text: String, image: Texture2D = null, link := "") -> void:
	_queue.append({
		"popup": target_popup,
		"text": text,
		"image": image,
		"link": link
	})
	_process_queue()


func _process_queue() -> void:
	if _showing or _queue.is_empty():
		return

	_showing = true
	var job: Dictionary = _queue.pop_front()

	var p: UIPopup = job["popup"]
	p.show_popup(job["text"], job["image"], job["link"])
	await p.finished

	_showing = false
	_process_queue()
	
	
#use insta popup
func popup_spacegram():
	SfxPlayer.notification_quest_sound()
	_enqueue(
		popup,
		tr("USE_SPACEGRAM"),
		load("res://assets/sprites/selfmade/Spacegram_Logo.png"),
		SPACEGRAM_URL
	)


#func popup_spacegram_de():
	#SfxPlayer.notification_quest_sound()
	#_enqueue(
		#popup,
		#"Nutze Spacegram!",
		#load("res://assets/sprites/selfmade/Spacegram_Logo.png"),
		#SPACEGRAM_URL
	#)
#
#func popup_spacegram_en():
	#SfxPlayer.notification_quest_sound()
	#_enqueue(
		#popup,
		#"Use Spacegram!",
		#load("res://assets/sprites/selfmade/Spacegram_Logo.png"),
		#SPACEGRAM_URL
	#)



#found item popup
func popup_item(item: String, icon: Texture2D):
	SfxPlayer.notification_sound()
	_enqueue(
		popup,
		tr("ITEM_FOUND") + ": " + item, icon)


#func popup_item_de(item: String, icon: Texture2D):
	#SfxPlayer.notification_sound()
	#_enqueue(
		#popup,
		#"Item gefunden: " + item, 
		#icon)
	#
#func popup_item_en(item: String, icon: Texture2D):
	#SfxPlayer.notification_sound()
	#_enqueue(
		#popup,
		#"Item found: " + item,
		#icon)

#found note popup
func popup_diary():
	SfxPlayer.notification_sound()
	_enqueue(
		popup,
		tr("NEW_DIARY_ENTRY"),
		load("res://assets/sprites/selfmade/note.png") as Texture2D)

#func popup_diary_en():
	#SfxPlayer.notification_sound()
	#_enqueue(
		#popup,
		#"New Diary entry!",
		#load("res://assets/sprites/selfmade/note.png") as Texture2D)
#
#func popup_diary_de():
	#SfxPlayer.notification_sound()
	#_enqueue(
		#popup,
		#"Neuer Tagebucheintrag!",
		#load("res://assets/sprites/selfmade/note.png") as Texture2D)
#

func popup_add_quest(quest: Dictionary):
	SfxPlayer.notification_quest_sound()
	_enqueue(
		quest_popup,
		tr("QUEST_NEW") + ": " + quest["title"],
		QUEST_ICON
	)

func popup_complete_quest(quest: Dictionary):
	SfxPlayer.notification_quest_sound()
	_enqueue(
		quest_popup,
		tr("QUEST_COMPLETED") + ": " + quest["title"],
		QUEST_ICON
	)

func popup_update_quest(quest: Dictionary):
	SfxPlayer.notification_quest_sound()
	_enqueue(
		quest_popup,
		tr("QUEST_UPDATED") + ": " + quest["title"],
		QUEST_ICON
	)
