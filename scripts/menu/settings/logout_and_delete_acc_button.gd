extends HBoxContainer

@onready var logout_button = $LogoutButton
@onready var delete_button = $DeleteButton

@export var settings_menu: Node

func _ready():
	logout_button.pressed.connect(_on_logout_pressed)
	delete_button.pressed.connect(_on_delete_pressed)
	
	
func _on_logout_pressed():
	NakamaManager.logout()

	get_tree().paused = false

	GameState.reset()
	SceneManager.stop_current_scene()
	
	var settings = get_tree().get_first_node_in_group("settings_menu")
	if settings:
		settings.update_auth_buttons()

	if settings_menu:
		settings_menu._on_close_button_pressed()

	SceneManager.goto_main_menu()
	
	
	
func _on_delete_pressed():
	var popup = GlobalUI.get_node("PopUp")

	var lang = TranslationServer.get_locale().substr(0, 2)

	if lang == "en":
		popup.open("Delete account?", func(): _confirm_delete_account())
	else:
		popup.open("Account wirklich löschen?", func(): _confirm_delete_account())
		

func _confirm_delete_account():
	if settings_menu:
		settings_menu._on_close_button_pressed()
	
	var result = await SpacegramApi.delete_my_account()

	if not result.success:
		print("Delete failed: ", result.error)
		return
	
	_on_logout_pressed()
	
	NakamaManager.logout()
	SceneManager.goto_main_menu()
	
	
	
