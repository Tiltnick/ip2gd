extends Node

var client
var session

func _ready():
	client = Nakama.create_client("defaultkey", "127.0.0.1", 7350, "http")
	client.timeout = 10
	print("Created Client: ", client)

	login_device()


func login_device():
	var device_id = OS.get_unique_id()
	print("Device ID: ", device_id)

	var result = await client.authenticate_device_async(device_id)

	if result.is_exception():
		print("Login Error: ", result)
		return

	session = result
	print("Successful Login: User ID: ", session.user_id)

	await save_test_post()
	await load_test_post()


func save_test_post():
	var post_data = {
		"author": "Sam",
		"caption": "Test Post 1",
		"likes": 5
	}

	var can_read = 2
	var can_write = 1
	var version = ""

	var write = NakamaWriteStorageObject.new(
		"spacegram_posts",
		"post_1",
		can_read,
		can_write,
		JSON.stringify(post_data),
		version
	)

	var acks = await client.write_storage_objects_async(session, [write])

	if acks.is_exception():
		print("Saving failed: ", acks)
		return

	print("Post saved successfully: ", acks)


func load_test_post():
	var object_ids = [
		NakamaStorageObjectId.new("spacegram_posts", "post_1", session.user_id)
	]

	var result = await client.read_storage_objects_async(session, object_ids)

	if result.is_exception():
		print("Reading failed: ", result)
		return

	print("Read objects: ", result.objects)

	if result.objects.size() == 0:
		print("Post not found.")
		return

	var raw_value = result.objects[0].value
	var json = JSON.new()
	var parse_result = json.parse(raw_value)

	if parse_result != OK:
		print("JSON Parse Error")
		return

	var post_data = json.data
	print("Loaded Post:")
	print("Author: ", post_data["author"])
	print("Caption: ", post_data["caption"])
	print("Likes: ", post_data["likes"])
