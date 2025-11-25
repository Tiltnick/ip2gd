extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	

func _on_button_pressed() -> void:
	show_popup()


func show_popup():
	visible = true
	$AnimationPlayer.play("slide_in")
	await get_tree().create_timer(3.0).timeout
	$AnimationPlayer.play("slide_out")
