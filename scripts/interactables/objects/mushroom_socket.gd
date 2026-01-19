extends Interactable
@onready var mushroom_ui: CanvasLayer = $"../MushroomUi"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()

func interact():
	SfxPlayer.ui_click_sound()
	mushroom_ui.open_socket()
