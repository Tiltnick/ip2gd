extends Control

@onready var anim := $AnimationPlayer
@onready var label: Label = $CanvasLayer/Panel/Label
@onready var icon: TextureRect = $CanvasLayer/Panel/TextureRect

func _ready():
	$CanvasLayer.visible = false

func show_popup(text: String, image: Texture2D = null):
	$CanvasLayer.visible = true
	# SfxPlayer.notification_sound() -> Audio ist im Popupmanager für verschiedene Sounds
	label.text = text
	if image != null:
		icon.texture= image 
	anim.play("slide_in")
	await get_tree().create_timer(4).timeout
	anim.play("slide_out")
