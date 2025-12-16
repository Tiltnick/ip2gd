extends Node

var popup_scene := preload("res://scenes/UI/spacegram_popup.tscn")
var popup: Control

func _ready():
	popup = popup_scene.instantiate()

	# In CanvasLayer packen
	var ui := CanvasLayer.new()
	get_tree().root.add_child.call_deferred(ui)
	ui.add_child(popup)

	popup.visible = false

#use insta popup
func popup_spacegram_de():
	popup.show_popup("Nutze Spacegram!", load("res://assets/sprites/selfmade/Spacegram_Logo.png") as Texture2D)

func popup_spacegram_en():
	popup.show_popup("Use Spacegram!", 
	load("res://assets/sprites/selfmade/Spacegram_Logo.png") as Texture2D)

#found item popup
func popup_item_de(item: String, icon: Texture2D):
	popup.show_popup("Item gefunden : " + item, icon)
	
func popup_item_en(item: String, icon: Texture2D):
	popup.show_popup("Item found : " + item, icon)

#found note popup
func popup_diary_en():
	popup.show_popup("New Diary entry!", load("res://assets/sprites/selfmade/note.png") as Texture2D)

func popup_diary_de():
	popup.show_popup("Neuer Tagebucheintrag!", load("res://assets/sprites/selfmade/note.png") as Texture2D)
