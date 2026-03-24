extends Node

var client
var session

func _ready():
	print("NakamaManager _ready: ", get_instance_id())
	client = Nakama.create_client("defaultkey", "127.0.0.1", 7350, "http")
	client.timeout = 10
	print("Created Client: ", client)


func login_device():
	print("login_device called on: ", get_instance_id())
	
	if session != null:
		print("Already logged in, skipping")
		return

	var device_id = OS.get_unique_id()
	print("Device ID: ", device_id)

	var result = await client.authenticate_device_async(device_id)

	if result.is_exception():
		print("Login Error: ", result)
		return

	session = result
	print("Successful Login: User ID: ", session.user_id)

func register_email(email: String, password: String, username: String = ""):
	if client == null:
		print("Client nicht initialisiert.")
		return

	var result = await client.authenticate_email_async(email, password, username, true)

	if result.is_exception():
		print("Register Error: ", result)
		return

	session = result
	print("Registration successful. User ID: ", session.user_id)

func login_email(email: String, password: String):

	if client == null:
		print("Client nicht initialisiert.")
		return

	var result = await client.authenticate_email_async(email, password, "", false)

	if result.is_exception():
		print("Login Error: ", result)
		return

	session = result
	print("Login successful. User ID: ", session.user_id)

func logout():
	if session == null:
		return

	var result = await client.session_logout_async(session)
	session = null
	print("Logged out.")

func is_logged_in() -> bool:
	return session != null
