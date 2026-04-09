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

func login_email(email: String, password: String) -> Dictionary:
	var result = await client.authenticate_email_async(email, password, "", false)

	if result == null:
		return {
			"success": false,
			"error": "ERROR_UNKNOWN"
		}

	if result.is_exception():
		var error = result as NakamaException
		var msg = error.message.to_lower()
		print("NAKAMA ERROR RAW:", msg)

		if msg.find("invalid email") != -1:
			return {"success": false, "error": "ERROR_INVALID_EMAIL"}

		elif msg.find("password") != -1 and msg.find("8") != -1:
			return {"success": false, "error": "ERROR_PASSWORD_TOO_SHORT"}

		elif msg.find("credentials") != -1:
			return {"success": false, "error": "ERROR_INVALID_LOGIN"}

		elif msg.find("exists") != -1:
			return {"success": false, "error": "ERROR_USER_EXISTS"}

		else:
			print("UNKNOWN ERROR FROM NAKAMA:", msg)
			return {"success": false, "error": "ERROR_UNKNOWN"}

	session = result
	return {
		"success": true
	}


func register_email(email: String, password: String, username: String) -> Dictionary:
	var result = await client.authenticate_email_async(email, password, username, true)

	if result == null:
		return {
			"success": false,
			"error": "ERROR_UNKNOWN"
		}

	if result.is_exception():
		var error_text := str(result)

		if "Invalid email address format" in error_text:
			return {"success": false, "error": "ERROR_INVALID_EMAIL"}
		elif "Password must be at least 8 characters long" in error_text:
			return {"success": false, "error": "ERROR_PASSWORD_TOO_SHORT"}
		elif "User account already exists" in error_text or "already exists" in error_text:
			return {"success": false, "error": "ERROR_USER_EXISTS"}
		else:
			return {"success": false, "error": "ERROR_UNKNOWN"}

	session = result
	return {
		"success": true
	}

func is_logged_in() -> bool:
	return session != null
