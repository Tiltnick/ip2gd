extends Control

@onready var anim := $AnimationPlayer

func _ready():
	visible = false

func show_popup():
	visible = true
	anim.play("slide_in")
	await get_tree().create_timer(3).timeout
	anim.play("slide_out")
