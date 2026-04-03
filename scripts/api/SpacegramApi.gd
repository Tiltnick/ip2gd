extends Node

const BASE_URL = "http://127.0.0.1:3000"

var http_request: HTTPRequest


func _ready():
	http_request = HTTPRequest.new()
	add_child(http_request)

	http_request.request_completed.connect(_on_request_completed)


func create_post(user_id: String, caption: String, image_path: String):
	var url = BASE_URL + "/posts"

	var body = {
		"user_id": user_id,
		"caption": caption,
		"image_path": image_path
	}

	var json_body = JSON.stringify(body)
	var headers = ["Content-Type: application/json"]

	var error = http_request.request(
		url,
		headers,
		HTTPClient.METHOD_POST,
		json_body
	)

	if error != OK:
		print("Request Fehler: ", error)


func _on_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		print("Request fehlgeschlagen")
		return

	var response_text = body.get_string_from_utf8()
	var json = JSON.parse_string(response_text)

	print("Response Code: ", response_code)
	print("Response JSON: ", json)
