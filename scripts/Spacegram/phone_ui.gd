extends CanvasLayer

@onready var spacegram_app = $PhoneFrame/Screen/SpacegramApp
@onready var camera_overlay = $CameraOverlay
#@onready var post_new_post_view = $PhoneFrame/Screen/SpacegramApp/ContentContainer/PostNewPostView
@onready var normal_phone_frame = $PhoneFrame
@onready var taste = $Taste
@onready var camera_panel = $Camera
@onready var normal_close_button = $CloseButton
@onready var normal_dim_background = $DimBackground

signal phone_closed


const BLOCKED_ACTIONS := [
	"hotbar_1",
	"hotbar_2",
	"hotbar_3",
	"hotbar_4",
	"toggle_inventory",
	"toggle_quests",
	"toggle_diary"
]

func _ready():
	visibility_changed.connect(_update_phone_state)
	_update_phone_state()
	
	normal_close_button.pressed.connect(close_phone)
	spacegram_app.open_camera_requested.connect(show_camera)
	camera_overlay.photo_confirmed.connect(show_new_post_view)
	camera_overlay.camera_closed.connect(close_camera)
	
func show_camera():
	spacegram_app.visible = false
	normal_phone_frame.visible = false
	taste.visible = false
	camera_panel.visible = false
	normal_close_button.visible = false
	normal_dim_background.visible = false

	camera_overlay.visible = true

func close_camera():

	camera_overlay.visible = false

	normal_phone_frame.visible = true
	taste.visible = true
	camera_panel.visible = true
	normal_close_button.visible = true
	normal_dim_background.visible = true

	spacegram_app.visible = true


func show_new_post_view(image_path: String):

	camera_overlay.visible = false

	normal_phone_frame.visible = true
	taste.visible = true
	camera_panel.visible = true
	normal_close_button.visible = true
	normal_dim_background.visible = true

	spacegram_app.visible = true

	spacegram_app.show_new_post_view(image_path)
	
	
func _update_phone_state() -> void:
	GameState.phone_open = visible
	
	
	
func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	for action in BLOCKED_ACTIONS:
		if event.is_action_pressed(action):
			get_viewport().set_input_as_handled()
			return
			
			
func open_phone() -> void:
	visible = true
	GameState.phone_open = true

	normal_phone_frame.visible = true
	taste.visible = true
	camera_panel.visible = true
	normal_close_button.visible = true
	normal_dim_background.visible = true
	camera_overlay.visible = false
	spacegram_app.visible = true

	if spacegram_app.has_method("show_feed"):
		await spacegram_app.show_feed()

	#if spacegram_app.has_method("show_feed"):
		#spacegram_app.show_feed()
	


func close_phone() -> void:
	visible = false
	GameState.phone_open = false
	phone_closed.emit()
