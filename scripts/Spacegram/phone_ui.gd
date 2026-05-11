extends CanvasLayer

@onready var spacegram_app = $PhoneFrame/Screen/SpacegramApp
@onready var camera_overlay = $CameraOverlay
#@onready var post_new_post_view = $PhoneFrame/Screen/SpacegramApp/ContentContainer/PostNewPostView
@onready var normal_phone_frame = $PhoneFrame
@onready var taste = $Taste
@onready var camera_panel = $Camera
@onready var normal_close_button = $CloseButton
@onready var normal_dim_background = $DimBackground

func _ready():
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


func show_new_post_view():

	camera_overlay.visible = false

	normal_phone_frame.visible = true
	taste.visible = true
	camera_panel.visible = true
	normal_close_button.visible = true
	normal_dim_background.visible = true

	spacegram_app.visible = true

	spacegram_app.show_new_post_view()
