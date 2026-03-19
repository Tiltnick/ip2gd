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
	


func is_logged_in() -> bool:
	return session != null
