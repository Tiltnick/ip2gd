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
	

func popup_show():
	popup.show_popup()
