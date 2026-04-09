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

	if not email.contains("@"):
		login_error.text = "ERROR_INVALID_EMAIL"
		login_error.visible = true
		return

	login_error.text = ""
	login_error.visible = false
	login_button.disabled = true

	var result = await NakamaManager.login_email(email, password)

	if result.success:
		print("Login erfolgreich")
		visible = false
	else:
		login_error.text = result.error
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
		print("Signup erfolgreich")
		visible = false
	else:
		signup_error.text = result.error
		signup_error.visible = true

	signup_button.disabled = false

	signup_button.disabled = false



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
