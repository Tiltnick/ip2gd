extends Node

const BASE_URL = "http://127.0.0.1:3000"

var http_request: HTTPRequest


func _ready():
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)


func create_post(caption: String, image_path: String):
	var url = BASE_URL + "/posts"

	var nakama_node = get_parent().get_node("NakamaManager")

	if nakama_node == null or nakama_node.session == null:
		print("Kein Nakama-Login vorhanden.")
		return

	var token = nakama_node.session.token

	var body = {
		"caption": caption,
		"image_path": image_path
	}

	var json_body = JSON.stringify(body)
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + token
	]

	var error = http_request.request(
		url,
		headers,
		HTTPClient.METHOD_POST,
		json_body
	)

	if error != OK:
		print("Request Fehler: ", error)


func get_posts():
	var url = BASE_URL + "/posts"

	var nakama_node = get_parent().get_node("NakamaManager")

	if nakama_node == null or nakama_node.session == null:
		print("Kein Nakama-Login vorhanden.")
		return

	var token = nakama_node.session.token

	var headers = [
		"Authorization: Bearer " + token
	]

	var error = http_request.request(
		url,
		headers,
		HTTPClient.METHOD_GET
	)

	if error != OK:
		print("Request Fehler: ", error)


func get_comments(post_id: String):
	var url = BASE_URL + "/posts/" + post_id + "/comments"

	var nakama_node = get_parent().get_node("NakamaManager")

	if nakama_node == null or nakama_node.session == null:
		print("Kein Login")
		return

	var token = nakama_node.session.token

	var headers = [
		"Authorization: Bearer " + token
	]

	http_request.request(url, headers, HTTPClient.METHOD_GET)


func like_post(post_id: String):
	var url = BASE_URL + "/posts/" + post_id + "/like"

	var nakama_node = get_parent().get_node("NakamaManager")

	if nakama_node == null or nakama_node.session == null:
		print("Kein Nakama-Login vorhanden.")
		return

	var token = nakama_node.session.token

	var headers = [
		"Authorization: Bearer " + token
	]

	var error = http_request.request(
		url,
		headers,
		HTTPClient.METHOD_POST
	)

	if error != OK:
		print("Request Fehler: ", error)


func unlike_post(post_id: String):
	var url = BASE_URL + "/posts/" + post_id + "/like"

	var nakama_node = get_parent().get_node("NakamaManager")

	if nakama_node == null or nakama_node.session == null:
		print("Kein Nakama-Login vorhanden.")
		return

	var token = nakama_node.session.token

	var headers = [
		"Authorization: Bearer " + token
	]

	var error = http_request.request(
		url,
		headers,
		HTTPClient.METHOD_DELETE
	)

	if error != OK:
		print("Request Fehler: ", error)

func get_my_profile():
	var url = BASE_URL + "/profile/me"

	var nakama_node = get_parent().get_node("NakamaManager")

	if nakama_node == null or nakama_node.session == null:
		print("Kein Nakama-Login vorhanden.")
		return

	var token = nakama_node.session.token

	var headers = [
		"Authorization: Bearer " + token
	]

	var error = http_request.request(
		url,
		headers,
		HTTPClient.METHOD_GET
	)

	if error != OK:
		print("Request Fehler: ", error)

func update_my_profile(display_name: String, bio: String, profile_picture: String):
	var url = BASE_URL + "/profile/me"

	var nakama_node = get_parent().get_node("NakamaManager")

	if nakama_node == null or nakama_node.session == null:
		print("Kein Nakama-Login vorhanden.")
		return

	var token = nakama_node.session.token

	var body = {
		"display_name": display_name,
		"bio": bio,
		"profile_picture": profile_picture
	}

	var json_body = JSON.stringify(body)
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + token
	]

	var error = http_request.request(
		url,
		headers,
		HTTPClient.METHOD_PUT,
		json_body
	)

	if error != OK:
		print("Request Fehler: ", error)

func _on_request_completed(result, response_code, headers, body):
	var response_text = body.get_string_from_utf8()

	if result != HTTPRequest.RESULT_SUCCESS:
		print("Request fehlgeschlagen")
		print("Response Code: ", response_code)
		print("Response Body: ", response_text)
		return

	var json = JSON.parse_string(response_text)

	print("Response Code: ", response_code)
	print("Response JSON: ", json)
