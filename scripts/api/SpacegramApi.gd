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


func create_post(caption: String, image_path: String) -> Dictionary:
	var url = BASE_URL + "/posts"
	var headers = _get_auth_headers(true)

	if headers.is_empty():
		return {
			"success": false,
			"data": null,
			"error": "ERROR_NOT_LOGGED_IN"
		}

	var body = {
		"caption": caption,
		"image_path": image_path
	}

	var json_body = JSON.stringify(body)

	var request_data = HTTPRequest.new()
	add_child(request_data)

	var error = request_data.request(
		url,
		headers,
		HTTPClient.METHOD_POST,
		json_body
	)

	if error != OK:
		request_data.queue_free()
		return {
			"success": false,
			"data": null,
			"error": "ERROR_REQUEST_FAILED"
		}

	var result = await request_data.request_completed
	var response_code = result[1]
	var response_text = result[3].get_string_from_utf8()

	request_data.queue_free()

	print("CREATE POST CODE: ", response_code)
	print("CREATE POST BODY: ", response_text)

	var json = JSON.parse_string(response_text)

	if json == null:
		return {
			"success": false,
			"data": null,
			"error": "ERROR_INVALID_JSON"
		}

	if response_code >= 200 and response_code < 300:
		return {
			"success": true,
			"data": json.get("data", null),
			"error": null
		}

	return {
		"success": false,
		"data": null,
		"error": json.get("error", "ERROR_UNKNOWN")
	}

func _get_unlocked_keys() -> Array[String]:
	var keys: Array[String] = []

	for key in GameState.puzzle_state.keys():
		if bool(GameState.puzzle_state.get(key, false)):
			keys.append(str(key))

	return keys


func _keys_to_query(keys: Array[String]) -> String:
	var encoded_keys: Array[String] = []

	for key in keys:
		encoded_keys.append(key.uri_encode())

	return ",".join(encoded_keys)

func get_posts() -> Dictionary:
	var url = BASE_URL + "/posts"
	var unlocked_keys := _get_unlocked_keys()
	
	print("Unlocked Keys für Feed: ", unlocked_keys)

	if not unlocked_keys.is_empty():
		url += "?unlocked_keys=" + _keys_to_query(unlocked_keys)
	
	print("GET POSTS URL: ", url)
	
	var headers = _get_auth_headers()

	if headers.is_empty():
		return {
			"success": false,
			"data": [],
			"error": "ERROR_NOT_LOGGED_IN"
		}

	var request_data = HTTPRequest.new()
	add_child(request_data)

	var error = request_data.request(
		url,
		headers,
		HTTPClient.METHOD_GET
	)

	if error != OK:
		request_data.queue_free()
		return {
			"success": false,
			"data": [],
			"error": "ERROR_REQUEST_FAILED"
		}

	var result = await request_data.request_completed
	var response_code = result[1]
	var response_text = result[3].get_string_from_utf8()

	request_data.queue_free()

	print("GET POSTS CODE: ", response_code)
	print("GET POSTS BODY: ", response_text)

	var json = JSON.parse_string(response_text)

	if json == null:
		return {
			"success": false,
			"data": [],
			"error": "ERROR_INVALID_JSON"
		}

	if response_code >= 200 and response_code < 300:
		return {
			"success": true,
			"data": json.get("data", []),
			"error": null
		}

	return {
		"success": false,
		"data": [],
		"error": json.get("error", "ERROR_UNKNOWN")
	}


func get_comments(post_id: String) -> Dictionary:
	var url = BASE_URL + "/posts/" + post_id + "/comments"
	var headers = _get_auth_headers()

	if headers.is_empty():
		return {
			"success": false,
			"data": [],
			"error": "ERROR_NOT_LOGGED_IN"
		}

	var request_data = HTTPRequest.new()
	add_child(request_data)

	var error = request_data.request(
		url,
		headers,
		HTTPClient.METHOD_GET
	)

	if error != OK:
		request_data.queue_free()
		return {
			"success": false,
			"data": [],
			"error": "ERROR_REQUEST_FAILED"
		}

	var result = await request_data.request_completed
	var response_code = result[1]
	var response_text = result[3].get_string_from_utf8()

	request_data.queue_free()

	print("GET COMMENTS CODE: ", response_code)
	print("GET COMMENTS BODY: ", response_text)

	var json = JSON.parse_string(response_text)

	if json == null:
		return {
			"success": false,
			"data": [],
			"error": "ERROR_INVALID_JSON"
		}

	if response_code >= 200 and response_code < 300:
		return {
			"success": true,
			"data": json.get("data", []),
			"error": null
		}

	return {
		"success": false,
		"data": [],
		"error": json.get("error", "ERROR_UNKNOWN")
	}


func like_post(post_id: String) -> Dictionary:
	var url = BASE_URL + "/posts/" + post_id + "/like"
	var headers = _get_auth_headers()

	if headers.is_empty():
		return {
			"success": false,
			"error": "ERROR_NOT_LOGGED_IN"
		}

	var request_data = HTTPRequest.new()
	add_child(request_data)

	var error = request_data.request(
		url,
		headers,
		HTTPClient.METHOD_POST
	)

	if error != OK:
		request_data.queue_free()
		return {
			"success": false,
			"error": "ERROR_REQUEST_FAILED"
		}

	var result = await request_data.request_completed
	var response_code = result[1]
	var response_text = result[3].get_string_from_utf8()

	request_data.queue_free()

	print("LIKE CODE: ", response_code)
	print("LIKE BODY: ", response_text)

	var json = JSON.parse_string(response_text)

	if response_code >= 200 and response_code < 300:
		return {
			"success": true,
			"data": json.get("data", null) if json != null else null,
			"error": null
		}

	return {
		"success": false,
		"error": json.get("error", "ERROR_UNKNOWN") if json != null else "ERROR_INVALID_JSON"
	}


func unlike_post(post_id: String) -> Dictionary:
	var url = BASE_URL + "/posts/" + post_id + "/like"
	var headers = _get_auth_headers()

	if headers.is_empty():
		return {
			"success": false,
			"error": "ERROR_NOT_LOGGED_IN"
		}

	var request_data = HTTPRequest.new()
	add_child(request_data)

	var error = request_data.request(
		url,
		headers,
		HTTPClient.METHOD_DELETE
	)

	if error != OK:
		request_data.queue_free()
		return {
			"success": false,
			"error": "ERROR_REQUEST_FAILED"
		}

	var result = await request_data.request_completed
	var response_code = result[1]
	var response_text = result[3].get_string_from_utf8()

	request_data.queue_free()

	print("UNLIKE CODE: ", response_code)
	print("UNLIKE BODY: ", response_text)

	var json = JSON.parse_string(response_text)

	if response_code >= 200 and response_code < 300:
		return {
			"success": true,
			"data": json.get("data", null) if json != null else null,
			"error": null
		}

	return {
		"success": false,
		"error": json.get("error", "ERROR_UNKNOWN") if json != null else "ERROR_INVALID_JSON"
	}


func get_my_profile() -> Dictionary:
	var url = BASE_URL + "/profile/me"
	var headers = _get_auth_headers()

	if headers.is_empty():
		return {
			"success": false,
			"data": null,
			"error": "ERROR_NOT_LOGGED_IN"
		}

	var request_data = HTTPRequest.new()
	add_child(request_data)

	var error = request_data.request(
		url,
		headers,
		HTTPClient.METHOD_GET
	)

	if error != OK:
		request_data.queue_free()
		return {
			"success": false,
			"data": null,
			"error": "ERROR_REQUEST_FAILED"
		}

	var result = await request_data.request_completed
	var response_code = result[1]
	var response_text = result[3].get_string_from_utf8()

	request_data.queue_free()

	print("GET MY PROFILE CODE: ", response_code)
	print("GET MY PROFILE BODY: ", response_text)

	var json = JSON.parse_string(response_text)

	if json == null:
		return {
			"success": false,
			"data": null,
			"error": "ERROR_INVALID_JSON"
		}

	if response_code >= 200 and response_code < 300:
		return {
			"success": true,
			"data": json.get("data", null),
			"error": null
		}

	return {
		"success": false,
		"data": null,
		"error": json.get("error", "ERROR_UNKNOWN")
	}


func update_my_profile(display_name: String, bio: String, profile_picture: String) -> Dictionary:
	var url = BASE_URL + "/profile/me"
	var headers = _get_auth_headers(true)

	if headers.is_empty():
		return {
			"success": false,
			"error": "ERROR_NOT_LOGGED_IN"
		}

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
		return {
			"success": false,
			"error": "ERROR_REQUEST_FAILED"
		}

	var result = await http_request.request_completed
	var response_code = result[1]
	var response_text = result[3].get_string_from_utf8()

	print("update_my_profile response code: ", response_code)
	print("update_my_profile response body: ", response_text)

	var json = JSON.parse_string(response_text)

	if response_code >= 200 and response_code < 300:
		return {
			"success": true,
			"data": json.get("data", null)
		}

	return {
		"success": false,
		"error": json.get("error", "ERROR_UNKNOWN")
	}

func delete_post(post_id: String) -> Dictionary:
	var url = BASE_URL + "/posts/" + post_id
	var headers = _get_auth_headers()

	if headers.is_empty():
		return {
			"success": false,
			"error": "ERROR_NOT_LOGGED_IN"
		}

	var request_data = HTTPRequest.new()
	add_child(request_data)

	var error = request_data.request(
		url,
		headers,
		HTTPClient.METHOD_DELETE
	)

	if error != OK:
		request_data.queue_free()
		return {
			"success": false,
			"error": "ERROR_REQUEST_FAILED"
		}

	var result = await request_data.request_completed
	var response_code = result[1]
	var response_text = result[3].get_string_from_utf8()

	request_data.queue_free()

	print("DELETE POST CODE: ", response_code)
	print("DELETE POST BODY: ", response_text)

	var json = JSON.parse_string(response_text)

	if response_code >= 200 and response_code < 300:
		return {
			"success": true,
			"error": null
		}

	return {
		"success": false,
		"error": json.get("error", "ERROR_UNKNOWN") if json != null else "ERROR_INVALID_JSON"
	}


func delete_comment(comment_id: String) -> Dictionary:
	var url = BASE_URL + "/posts/comments/" + comment_id
	var headers = _get_auth_headers()

	if headers.is_empty():
		return {
			"success": false,
			"error": "ERROR_NOT_LOGGED_IN"
		}

	var request_data = HTTPRequest.new()
	add_child(request_data)

	var error = request_data.request(
		url,
		headers,
		HTTPClient.METHOD_DELETE
	)

	if error != OK:
		request_data.queue_free()
		return {
			"success": false,
			"error": "ERROR_REQUEST_FAILED"
		}

	var result = await request_data.request_completed
	var response_code = result[1]
	var response_text = result[3].get_string_from_utf8()

	request_data.queue_free()

	print("DELETE COMMENT CODE: ", response_code)
	print("DELETE COMMENT BODY: ", response_text)

	var json = JSON.parse_string(response_text)

	if response_code >= 200 and response_code < 300:
		return {
			"success": true,
			"error": null
		}

	return {
		"success": false,
		"error": json.get("error", "ERROR_UNKNOWN") if json != null else "ERROR_INVALID_JSON"
	}


func get_profile_by_user_id(user_id: String) -> Dictionary:
	var url = BASE_URL + "/profile/" + user_id
	var headers = _get_auth_headers()

	if headers.is_empty():
		return {
			"success": false,
			"data": null,
			"error": "ERROR_NOT_LOGGED_IN"
		}

	var request_data = HTTPRequest.new()
	add_child(request_data)

	var error = request_data.request(
		url,
		headers,
		HTTPClient.METHOD_GET
	)

	if error != OK:
		request_data.queue_free()
		return {
			"success": false,
			"data": null,
			"error": "ERROR_REQUEST_FAILED"
		}

	var result = await request_data.request_completed
	var response_code = result[1]
	var response_text = result[3].get_string_from_utf8()

	request_data.queue_free()

	print("GET PROFILE BY USER ID CODE: ", response_code)
	print("GET PROFILE BY USER ID BODY: ", response_text)

	var json = JSON.parse_string(response_text)

	if json == null:
		return {
			"success": false,
			"data": null,
			"error": "ERROR_INVALID_JSON"
		}

	if response_code >= 200 and response_code < 300:
		return {
			"success": true,
			"data": json.get("data", null),
			"error": null
		}

	return {
		"success": false,
		"data": null,
		"error": json.get("error", "ERROR_UNKNOWN")
	}

func create_comment(post_id: String, text: String, parent_comment_id: String = "") -> Dictionary:
	var url = BASE_URL + "/posts/" + post_id + "/comments"
	var headers = _get_auth_headers(true)

	if headers.is_empty():
		return {
			"success": false,
			"data": null,
			"error": "ERROR_NOT_LOGGED_IN"
		}

	var body = {
		"text": text
	}
	
	if not parent_comment_id.is_empty():
		body["parent_comment_id"] = parent_comment_id

	var json_body = JSON.stringify(body)

	var request_data = HTTPRequest.new()
	add_child(request_data)

	var error = request_data.request(
		url,
		headers,
		HTTPClient.METHOD_POST,
		json_body
	)

	if error != OK:
		request_data.queue_free()
		return {
			"success": false,
			"data": null,
			"error": "ERROR_REQUEST_FAILED"
		}

	var result = await request_data.request_completed
	var response_code = result[1]
	var response_text = result[3].get_string_from_utf8()

	request_data.queue_free()

	print("CREATE COMMENT CODE: ", response_code)
	print("CREATE COMMENT BODY: ", response_text)

	var json = JSON.parse_string(response_text)

	if json == null:
		return {
			"success": false,
			"data": null,
			"error": "ERROR_INVALID_JSON"
		}

	if response_code >= 200 and response_code < 300:
		return {
			"success": true,
			"data": json.get("data", null),
			"error": null
		}

	return {
		"success": false,
		"data": null,
		"error": json.get("error", "ERROR_UNKNOWN")
	}
		
		
func delete_my_account() -> Dictionary:
	var url = BASE_URL + "/account/me"
	var headers = _get_auth_headers()
	print("AUTH HEADERS:", headers)

	if headers.is_empty():
		return {
			"success": false,
			"error": "ERROR_NOT_LOGGED_IN"
		}

	
	var request_data = HTTPRequest.new()
	add_child(request_data)

	var error = request_data.request(
		url,
		headers,
		HTTPClient.METHOD_DELETE
	)

	if error != OK:
		request_data.queue_free()
		return {
			"success": false,
			"error": "ERROR_REQUEST_FAILED"
		}
	print("RAWR ERROR:", error)
	var result = await request_data.request_completed
	print("0: RESONSE RESULT", result[0])
	var response_code = result[1]
	var response_text = result[3].get_string_from_utf8()

	request_data.queue_free() 

	print("DELETE RESPONSE CODE: ", response_code)
	print("DELETE RESPONSE TEXT: ", response_text)

	var json = JSON.parse_string(response_text)

	if response_code >= 200 and response_code < 300:
		return {"success": true}

	if json == null:
		return {
			"success": false,
			"error": "ERROR_NO_JSON_RESPONSE"
		}

	return {
	"success": false,
	"error": json.get("error", "ERROR_UNKNOWN")
	}
	
	


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
	
	
func follow_user(user_id: String) -> Dictionary:
	var url = BASE_URL + "/profile/" + user_id + "/follow"
	var headers = _get_auth_headers()

	if headers.is_empty():
		return {
			"success": false,
			"error": "ERROR_NOT_LOGGED_IN"
		}

	var request_data = HTTPRequest.new()
	add_child(request_data)

	var error = request_data.request(
		url,
		headers,
		HTTPClient.METHOD_POST
	)

	if error != OK:
		request_data.queue_free()
		return {
			"success": false,
			"error": "ERROR_REQUEST_FAILED"
		}

	var result = await request_data.request_completed
	var response_code = result[1]
	var response_text = result[3].get_string_from_utf8()

	request_data.queue_free()

	print("FOLLOW CODE: ", response_code)
	print("FOLLOW BODY: ", response_text)

	var json = JSON.parse_string(response_text)

	if response_code >= 200 and response_code < 300:
		return {
			"success": true,
			"data": json.get("data", null) if json != null else null,
			"error": null
		}

	return {
		"success": false,
		"error": json.get("error", "ERROR_UNKNOWN") if json != null else "ERROR_INVALID_JSON"
	}


func unfollow_user(user_id: String) -> Dictionary:
	var url = BASE_URL + "/profile/" + user_id + "/follow"
	var headers = _get_auth_headers()

	if headers.is_empty():
		return {
			"success": false,
			"error": "ERROR_NOT_LOGGED_IN"
		}

	var request_data = HTTPRequest.new()
	add_child(request_data)

	var error = request_data.request(
		url,
		headers,
		HTTPClient.METHOD_DELETE
	)

	if error != OK:
		request_data.queue_free()
		return {
			"success": false,
			"error": "ERROR_REQUEST_FAILED"
		}

	var result = await request_data.request_completed
	var response_code = result[1]
	var response_text = result[3].get_string_from_utf8()

	request_data.queue_free()

	print("UNFOLLOW CODE: ", response_code)
	print("UNFOLLOW BODY: ", response_text)

	var json = JSON.parse_string(response_text)

	if response_code >= 200 and response_code < 300:
		return {
			"success": true,
			"error": null
		}

	return {
		"success": false,
		"error": json.get("error", "ERROR_UNKNOWN") if json != null else "ERROR_INVALID_JSON"
	}


func get_following() -> Dictionary:
	var url = BASE_URL + "/profile/following"
	var headers = _get_auth_headers()

	if headers.is_empty():
		return {
			"success": false,
			"data": [],
			"error": "ERROR_NOT_LOGGED_IN"
		}

	var request_data = HTTPRequest.new()
	add_child(request_data)

	var error = request_data.request(
		url,
		headers,
		HTTPClient.METHOD_GET
	)

	if error != OK:
		request_data.queue_free()
		return {
			"success": false,
			"data": [],
			"error": "ERROR_REQUEST_FAILED"
		}

	var result = await request_data.request_completed
	var response_code = result[1]
	var response_text = result[3].get_string_from_utf8()

	request_data.queue_free()

	print("GET FOLLOWING CODE: ", response_code)
	print("GET FOLLOWING BODY: ", response_text)

	var json = JSON.parse_string(response_text)

	if response_code >= 200 and response_code < 300:
		return {
			"success": true,
			"data": json.get("data", []) if json != null else [],
			"error": null
		}

	return {
		"success": false,
		"data": [],
		"error": json.get("error", "ERROR_UNKNOWN") if json != null else "ERROR_INVALID_JSON"
	}



func like_comment(comment_id: String) -> Dictionary:
	var url = BASE_URL + "/posts/comments/" + comment_id + "/like"
	var headers = _get_auth_headers()

	if headers.is_empty():
		return {
			"success": false,
			"error": "ERROR_NOT_LOGGED_IN"
		}

	var request_data = HTTPRequest.new()
	add_child(request_data)

	var error = request_data.request(
		url,
		headers,
		HTTPClient.METHOD_POST
	)

	if error != OK:
		request_data.queue_free()
		return {
			"success": false,
			"error": "ERROR_REQUEST_FAILED"
		}

	var result = await request_data.request_completed
	var response_code = result[1]
	var response_text = result[3].get_string_from_utf8()

	request_data.queue_free()

	print("LIKE COMMENT CODE: ", response_code)
	print("LIKE COMMENT BODY: ", response_text)

	var json = JSON.parse_string(response_text)

	if response_code >= 200 and response_code < 300:
		return {
			"success": true,
			"data": json.get("data", null) if json != null else null,
			"error": null
		}

	return {
		"success": false,
		"error": json.get("error", "ERROR_UNKNOWN") if json != null else "ERROR_INVALID_JSON"
	}


func unlike_comment(comment_id: String) -> Dictionary:
	var url = BASE_URL + "/posts/comments/" + comment_id + "/like"
	var headers = _get_auth_headers()

	if headers.is_empty():
		return {
			"success": false,
			"error": "ERROR_NOT_LOGGED_IN"
		}

	var request_data = HTTPRequest.new()
	add_child(request_data)

	var error = request_data.request(
		url,
		headers,
		HTTPClient.METHOD_DELETE
	)

	if error != OK:
		request_data.queue_free()
		return {
			"success": false,
			"error": "ERROR_REQUEST_FAILED"
		}

	var result = await request_data.request_completed
	var response_code = result[1]
	var response_text = result[3].get_string_from_utf8()

	request_data.queue_free()

	print("UNLIKE COMMENT CODE: ", response_code)
	print("UNLIKE COMMENT BODY: ", response_text)

	var json = JSON.parse_string(response_text)

	if response_code >= 200 and response_code < 300:
		return {
			"success": true,
			"error": null
		}

	return {
		"success": false,
		"error": json.get("error", "ERROR_UNKNOWN") if json != null else "ERROR_INVALID_JSON"
	}
