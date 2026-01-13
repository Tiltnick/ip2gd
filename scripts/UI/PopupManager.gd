extends Node

var QUEST_ICON := preload("res://assets/sprites/selfmade/Quest_Icon.png")

var popup_scene := preload("res://scenes/UI/Popup.tscn")
var quest_popup_scene := preload("res://scenes/UI/Quest_Popup.tscn")
var popup: Control
var quest_popup: Control

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

#use insta popup
func popup_spacegram_de():
	SfxPlayer.notification_quest_sound()
	popup.show_popup("Nutze Spacegram!", load("res://assets/sprites/selfmade/Spacegram_Logo.png") as Texture2D)

func popup_spacegram_en():
	SfxPlayer.notification_quest_sound()
	popup.show_popup("Use Spacegram!", 
	load("res://assets/sprites/selfmade/Spacegram_Logo.png") as Texture2D)

#found item popup
func popup_item_de(item: String, icon: Texture2D):
	SfxPlayer.notification_sound()
	popup.show_popup("Item gefunden: " + item, icon)
	
func popup_item_en(item: String, icon: Texture2D):
	SfxPlayer.notification_sound()
	popup.show_popup("Item found: " + item, icon)

#found note popup
func popup_diary_en():
	SfxPlayer.notification_sound()
	popup.show_popup("New Diary entry!", load("res://assets/sprites/selfmade/note.png") as Texture2D)

func popup_diary_de():
	SfxPlayer.notification_sound()
	popup.show_popup("Neuer Tagebucheintrag!", load("res://assets/sprites/selfmade/note.png") as Texture2D)


func popup_add_quest(quest: Dictionary):
	SfxPlayer.notification_quest_sound()
	quest_popup.show_popup(
		tr("QUEST_NEW") + ": " + quest["title"],
		QUEST_ICON
	)

func popup_complete_quest(quest: Dictionary):
	SfxPlayer.notification_quest_sound()
	quest_popup.show_popup(
		tr("QUEST_COMPLETED") + ": " + quest["title"],
		QUEST_ICON
	)
