extends Node

var client
var session

func _ready():
	client = Nakama.create_client("defaultkey", "127.0.0.1", 7350, "http")
	client.timeout = 10
	print("Created Client: ", client)

	await login_device()


func login_device():
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
		return {"success": false, "error": "ERROR_UNKNOWN"}

	if result.is_exception():
		var error_text := str(result).to_lower()

		if "invalid email" in error_text:
			return {"success": false, "error": "ERROR_INVALID_EMAIL"}
		elif "password" in error_text and "8" in error_text:
			return {"success": false, "error": "ERROR_PASSWORD_TOO_SHORT"}
		elif "credentials" in error_text:
			return {"success": false, "error": "ERROR_INVALID_LOGIN"}
		else:
			return {"success": false, "error": "ERROR_UNKNOWN"}

	session = result
	return {"success": true}


func register_email(email: String, password: String) -> Dictionary:
	var result = await client.authenticate_email_async(email, password, "", true)

	if result == null:
		return {"success": false, "error": "ERROR_UNKNOWN"}

	if result.is_exception():
		var error_text := str(result).to_lower()
		print("REGISTER ERROR TEXT: ", error_text)

		if "invalid email" in error_text:
			return {"success": false, "error": "ERROR_INVALID_EMAIL"}
		elif "password" in error_text and "8" in error_text:
			return {"success": false, "error": "ERROR_PASSWORD_TOO_SHORT"}
		elif "already exists" in error_text:
			return {"success": false, "error": "ERROR_USER_EXISTS"}
		elif "invalid credentials" in error_text:
			return {"success": false, "error": "ERROR_USER_EXISTS"}
		else:
			return {"success": false, "error": "ERROR_UNKNOWN"}

	session = result
	return {"success": true}

func is_logged_in() -> bool:
	return session != null
	
func logout():
	session = null
