extends Control

@onready var anim := $AnimationPlayer
@onready var label: Label = $CanvasLayer/Panel/Label
@onready var icon: TextureRect = $CanvasLayer/Panel/TextureRect

func _ready():
	visible = false

func show_popup(text: String, image: Texture2D = null):
	SfxPlayer.notification_sound()
	visible = true
	label.text = text
	if image != null:
		icon.texture= image 
	anim.play("slide_in")
	await get_tree().create_timer(3).timeout
	anim.play("slide_out")
