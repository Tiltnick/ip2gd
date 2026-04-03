extends Node

const BASE_URL = "http://127.0.0.1:3000"

var http_request: HTTPRequest


func _ready():
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)


func _get_auth_headers(include_json: bool = false) -> Array:
	if not NakamaManager.is_logged_in():
		print("Kein Nakama-Login vorhanden.")
		return []

	var token = NakamaManager.session.token
	var headers: Array = []

	if include_json:
		headers.append("Content-Type: application/json")

	headers.append("Authorization: Bearer " + token)
	return headers


func create_post(caption: String, image_path: String):
	var url = BASE_URL + "/posts"
	var headers = _get_auth_headers(true)

	if headers.is_empty():
		return

	var body = {
		"caption": caption,
		"image_path": image_path
	}

	var json_body = JSON.stringify(body)

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
	var headers = _get_auth_headers()

	if headers.is_empty():
		return

	var error = http_request.request(
		url,
		headers,
		HTTPClient.METHOD_GET
	)

	if error != OK:
		print("Request Fehler: ", error)


func get_comments(post_id: String):
	var url = BASE_URL + "/posts/" + post_id + "/comments"
	var headers = _get_auth_headers()

	if headers.is_empty():
		return

	var error = http_request.request(
		url,
		headers,
		HTTPClient.METHOD_GET
	)

	if error != OK:
		print("Request Fehler: ", error)


func like_post(post_id: String):
	var url = BASE_URL + "/posts/" + post_id + "/like"
	var headers = _get_auth_headers()

	if headers.is_empty():
		return

	var error = http_request.request(
		url,
		headers,
		HTTPClient.METHOD_POST
	)

	if error != OK:
		print("Request Fehler: ", error)


func unlike_post(post_id: String):
	var url = BASE_URL + "/posts/" + post_id + "/like"
	var headers = _get_auth_headers()

	if headers.is_empty():
		return

	var error = http_request.request(
		url,
		headers,
		HTTPClient.METHOD_DELETE
	)

	if error != OK:
		print("Request Fehler: ", error)


func get_my_profile():
	var url = BASE_URL + "/profile/me"
	var headers = _get_auth_headers()

	if headers.is_empty():
		return

	var error = http_request.request(
		url,
		headers,
		HTTPClient.METHOD_GET
	)

	if error != OK:
		print("Request Fehler: ", error)


func update_my_profile(display_name: String, bio: String, profile_picture: String):
	var url = BASE_URL + "/profile/me"
	var headers = _get_auth_headers(true)

	if headers.is_empty():
		return

	var body = {
		"display_name": display_name,
		"bio": bio,
		"profile_picture": profile_picture
	}

	var json_body = JSON.stringify(body)

	var error = http_request.request(
		url,
		headers,
		HTTPClient.METHOD_PUT,
		json_body
	)

	if error != OK:
		print("Request Fehler: ", error)

func delete_post(post_id: String):
	var url = BASE_URL + "/posts/" + post_id
	var headers = _get_auth_headers()

	if headers.is_empty():
		return

	var error = http_request.request(
		url,
		headers,
		HTTPClient.METHOD_DELETE
	)

	if error != OK:
		print("Request Fehler: ", error)


func delete_comment(comment_id: String):
	var url = BASE_URL + "/posts/comments/" + comment_id
	var headers = _get_auth_headers()

	if headers.is_empty():
		return

	var error = http_request.request(
		url,
		headers,
		HTTPClient.METHOD_DELETE
	)

	if error != OK:
		print("Request Fehler: ", error)


func get_profile_by_user_id(user_id: String):
	var url = BASE_URL + "/profile/" + user_id
	var headers = _get_auth_headers()

	if headers.is_empty():
		return

	var error = http_request.request(
		url,
		headers,
		HTTPClient.METHOD_GET
	)

	if error != OK:
		print("Request Fehler: ", error)

func create_comment(post_id: String, text: String):
	var url = BASE_URL + "/posts/" + post_id + "/comments"
	var headers = _get_auth_headers(true)

	if headers.is_empty():
		return

	var body = {
		"text": text
	}

	var json_body = JSON.stringify(body)

	var error = http_request.request(
		url,
		headers,
		HTTPClient.METHOD_POST,
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
