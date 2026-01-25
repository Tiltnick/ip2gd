extends Control
class_name UIPopup

signal finished

@onready var anim := $AnimationPlayer
@onready var label: Label = $CanvasLayer/Panel/Label
@onready var icon: TextureRect = $CanvasLayer/Panel/TextureRect

var icon_link := ""

func _ready():
	$CanvasLayer.visible = false
	icon.mouse_filter = Control.MOUSE_FILTER_STOP
	icon.gui_input.connect(_on_icon_input)

func show_popup(text: String, image: Texture2D = null, link := ""):
	$CanvasLayer.visible = true
	
	label.text = text
	icon.texture = image
	icon_link = link

	anim.play("slide_in")
	await get_tree().create_timer(4).timeout
	anim.play("slide_out")
	
	await anim.animation_finished
	$CanvasLayer.visible = false
	finished.emit()

func _on_icon_input(event):
	if icon_link == "":
		return

	if event is InputEventMouseButton and event.pressed:
		SfxPlayer.ui_click_sound()
		OS.shell_open(icon_link)
