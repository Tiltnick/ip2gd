extends Control

@onready var anim := $AnimationPlayer
@onready var icon: Sprite2D = $CanvasLayer/Panel/Sprite2D
@onready var label: Label = $CanvasLayer/Panel/Label

func _ready():
	visible = false

func show_popup(text: String, image: Texture2D = null):
	visible = true
	label.text = text
	if image != null:
		icon.texture= image 
	anim.play("slide_in")
	await get_tree().create_timer(3).timeout
	anim.play("slide_out")
