extends CanvasLayer

@onready var tab_container = $Root/WindowPanel/TabContainer

# Login
@onready var login_email = $Root/WindowPanel/TabContainer/LOGIN/LoginCenter/LoginForm/MarginContainer/VBoxContainer/LoginEmailField/MarginContainer/HBoxContainer/LineEdit
@onready var login_password = $Root/WindowPanel/TabContainer/LOGIN/LoginCenter/LoginForm/MarginContainer/VBoxContainer/LoginPasswordField/MarginContainer/HBoxContainer/PasswordLineEdit
@onready var login_button = $Root/WindowPanel/TabContainer/LOGIN/LoginCenter/LoginForm/MarginContainer/VBoxContainer/LoginSubmitButton
@onready var login_error = $Root/WindowPanel/TabContainer/LOGIN/LoginCenter/LoginForm/MarginContainer/VBoxContainer/LoginErrorLabel

# Signup
@onready var signup_username = $Root/WindowPanel/TabContainer/SIGN_UP/SignupCenter/SignupForm/MarginContainer/VBoxContainer/SignupUsernameField/MarginContainer/HBoxContainer/Username
@onready var signup_email = $Root/WindowPanel/TabContainer/SIGN_UP/SignupCenter/SignupForm/MarginContainer/VBoxContainer/SignupEmailField/MarginContainer/HBoxContainer/LineEdit
@onready var signup_password = $Root/WindowPanel/TabContainer/SIGN_UP/SignupCenter/SignupForm/MarginContainer/VBoxContainer/SignupPasswordField/MarginContainer/HBoxContainer/PasswordSignup
@onready var signup_button = $Root/WindowPanel/TabContainer/SIGN_UP/SignupCenter/SignupForm/MarginContainer/VBoxContainer/SignupSubmitButton
@onready var signup_error = $Root/WindowPanel/TabContainer/SIGN_UP/SignupCenter/SignupForm/MarginContainer/VBoxContainer/SignupErrorLabel

@onready var login_eye_button = $Root/WindowPanel/TabContainer/LOGIN/LoginCenter/LoginForm/MarginContainer/VBoxContainer/LoginPasswordField/MarginContainer/HBoxContainer/EyeButton
@onready var signup_eye_button = $Root/WindowPanel/TabContainer/SIGN_UP/SignupCenter/SignupForm/MarginContainer/VBoxContainer/SignupPasswordField/MarginContainer/HBoxContainer/EyeButton

var login_password_visible := false
var signup_password_visible := false

var eye_open = preload("res://assets/sprites/ui/eye (1).png")
var eye_closed = preload("res://assets/sprites/ui/hide (2).png")


func _ready():
	login_button.pressed.connect(_on_login_pressed)
	signup_button.pressed.connect(_on_signup_pressed)

	login_error.visible = false
	signup_error.visible = false
	
	
	

func _on_login_pressed():
	var email = login_email.text.strip_edges()
	var password = login_password.text.strip_edges()

	if email.is_empty() or password.is_empty():
		login_error.text = "ERROR_EMPTY_FIELDS"
		login_error.visible = true
		return

	if not is_valid_email(email):
		login_error.text = "ERROR_INVALID_EMAIL"
		login_error.visible = true
		return

	login_error.text = ""
	login_error.visible = false
	login_button.disabled = true

	var result = await NakamaManager.login_email(email, password)

	if result.success:
		var has_save = await SaveSystem.load_game()

		get_parent().update_resume_button(has_save)  # HIER

		visible = false
		

	else:
		login_error.text = "ERROR_INVALID_LOGIN"
		login_error.visible = true

	login_button.disabled = false



func _on_signup_pressed():
	var username = signup_username.text.strip_edges()
	var email = signup_email.text.strip_edges()
	var password = signup_password.text.strip_edges()

	if username.is_empty() or email.is_empty() or password.is_empty():
		signup_error.text = "ERROR_EMPTY_FIELDS"
		signup_error.visible = true
		return

	if not email.contains("@"):
		signup_error.text = "ERROR_INVALID_EMAIL"
		signup_error.visible = true
		return

	if password.length() < 8:
		signup_error.text = "ERROR_PASSWORD_TOO_SHORT"
		signup_error.visible = true
		return

	signup_error.text = ""
	signup_error.visible = false
	signup_button.disabled = true

	var result = await NakamaManager.register_email(email, password, username)

	if result.success:
		GameState.has_save = false
		visible = false
	else:
		signup_error.text = result.error
		signup_error.visible = true

	signup_button.disabled = false

	signup_button.disabled = false


func _on_signup_text_changed(_new_text: String):
	validate_signup()
	
func validate_signup():
	var email = signup_email.text
	var password = signup_password.text
	var username = signup_username.text

	if not email.is_empty() and not is_valid_email(email):
		show_signup_error("ERROR_INVALID_EMAIL")
		return

	if not password.is_empty() and password.length() < 8:
		show_signup_error("ERROR_PASSWORD_TOO_SHORT")
		return

	if not username.is_empty() and username.length() < 3:
		show_signup_error("ERROR_USERNAME_TOO_SHORT")
		return

	hide_signup_error()

	
	
func validate_login():
	var email = login_email.text
	var password = login_password.text

	if not email.is_empty() and not is_valid_email(email):
		show_login_error("ERROR_INVALID_EMAIL")
		return

	#if not password.is_empty() and password.length() < 8:
		#show_login_error("ERROR_PASSWORD_TOO_SHORT")
		#return
		
	

	hide_login_error()

func is_valid_email(email: String) -> bool:
	if email.count("@") != 1:
		return false

	var parts = email.split("@")
	if parts[0].length() < 1:
		return false

	if not parts[1].contains("."):
		return false

	return true

func _on_login_text_changed(_new_text: String):
	validate_login()
	


func show_signup_error(key: String):
	signup_error.text = key
	signup_error.visible = true

func hide_signup_error():
	signup_error.visible = false


func show_login_error(key: String):
	login_error.text = key
	login_error.visible = true

func hide_login_error():
	login_error.visible = false


func toggle_password_visibility(password_field: LineEdit, button: TextureButton):
	password_field.secret = not password_field.secret
	
	if password_field.secret:
		button.texture_normal = eye_closed
	else:
		button.texture_normal = eye_open

func _on_login_eye_button_pressed():
	toggle_password_visibility(login_password, login_eye_button)
	
func _on_signup_eye_button_pressed():
	toggle_password_visibility(signup_password, signup_eye_button)



func _map_error(error: String) -> String:
	if error == null:
		return "ERROR_UNKNOWN"

	if "Password must be" in error:
		return "ERROR_PASSWORD_TOO_SHORT"
	elif "Invalid credentials" in error:
		return "ERROR_INVALID_LOGIN"
	elif "User already exists" in error:
		return "ERROR_USER_EXISTS"
	else:
		return "ERROR_UNKNOWN"
