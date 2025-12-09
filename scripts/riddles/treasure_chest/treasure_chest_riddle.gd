extends CanvasLayer

@export var code = ["1", "1", "1"]

@onready var inputs = [
	$Control/Panel2/HBoxContainer/Input1,
	$Control/Panel2/HBoxContainer/Input2,
	$Control/Panel2/HBoxContainer/Input3
]



func _on_exit_pressed() -> void:
	hide()
	

func _on_round_buttton_pressed() -> void:
	hide()
	
