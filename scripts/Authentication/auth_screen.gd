extends CanvasLayer

@onready var tab_container = $Root/WindowPanel/TabContainer

# Login
@onready var login_email = $Root/WindowPanel/TabContainer/LOGIN/LoginCenter/LoginForm/MarginContainer/VBoxContainer/LoginEmailField/MarginContainer/HBoxContainer/LineEdit
@onready var login_password = $Root/WindowPanel/TabContainer/LOGIN/LoginCenter/LoginForm/MarginContainer/VBoxContainer/LoginPasswordField/MarginContainer/HBoxContainer/PasswordLineEdit
@onready var login_button = $Root/WindowPanel/TabContainer/LOGIN/LoginCenter/LoginForm/MarginContainer/VBoxContainer/LoginSubmitButton
@onready var login_error = $Root/WindowPanel/TabContainer/LOGIN/LoginCenter/LoginForm/MarginContainer/VBoxContainer/LoginErrorLabel

# Signuo
@onready var signup_username = $Root/WindowPanel/TabContainer/SIGN_UP/SignupCenter/SignupForm/MarginContainer/VBoxContainer/SignupUsernameField/MarginContainer/HBoxContainer/Username
@onready var signup_email = $Root/WindowPanel/TabContainer/SIGN_UP/SignupCenter/SignupForm/MarginContainer/VBoxContainer/SignupEmailField/MarginContainer/HBoxContainer/LineEdit
@onready var signup_password = $Root/WindowPanel/TabContainer/SIGN_UP/SignupCenter/SignupForm/MarginContainer/VBoxContainer/SignupPasswordField/MarginContainer/HBoxContainer/PasswordSignup
@onready var signup_button = $Root/WindowPanel/TabContainer/SIGN_UP/SignupCenter/SignupForm/MarginContainer/VBoxContainer/SignupSubmitButton
@onready var signup_error = $Root/WindowPanel/TabContainer/SIGN_UP/SignupCenter/SignupForm/MarginContainer/VBoxContainer/SignupErrorLabel


func _ready():
	login_button.pressed.connect(_on_login_pressed)
	signup_button.pressed.connect(_on_signup_pressed)


func _on_login_pressed():
	var email = login_email.text.strip_edges()
	var password = login_password.text.strip_edges()

	if email.is_empty() or password.is_empty():
		login_error.text = "Bitte alles ausfüllen"
		return

	login_error.text = ""
	login_button.disabled = true

	var success = await NakamaManager.login_email(email, password)

	if success:
		print("Login erfolgreich")
		SceneManager.goto_main_menu()
	else:
		login_error.text = "Login fehlgeschlagen"

	login_button.disabled = false


func _on_signup_pressed():
	var username = signup_username.text.strip_edges()
	var email = signup_email.text.strip_edges()
	var password = signup_password.text.strip_edges()

	if username.is_empty() or email.is_empty() or password.is_empty():
		signup_error.text = "Bitte alles ausfüllen"
		return

	signup_error.text = ""
	signup_button.disabled = true

	var success = await NakamaManager.register_email(email, password, username)

	if success:
		print("Signup erfolgreich")
		SceneManager.goto_main_menu()
	else:
		signup_error.text = "Signup fehlgeschlagen"

	signup_button.disabled = false
