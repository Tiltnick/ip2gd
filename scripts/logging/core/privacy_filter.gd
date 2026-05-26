extends RefCounted
class_name LogPrivacyFilter

const REDACTED_VALUE := "[REDACTED]"
const DEFAULT_BLOCKED_KEYS: Array[String] = [
	"name",
	"first_name",
	"last_name",
	"full_name",
	"user_name",
	"username",
	"email",
	"mail",
	"phone",
	"mobile",
	"ip",
	"ip_address",
	"address",
	"street",
	"zip",
	"postal_code",
]

var _blocked_keys: Array[String] = []
var _email_regex: RegEx = RegEx.new()
var _ipv4_regex: RegEx = RegEx.new()


func _init(extra_blocked_keys: Array = []) -> void:
	for key in DEFAULT_BLOCKED_KEYS:
		_blocked_keys.append(key.to_lower())
	for key in extra_blocked_keys:
		_blocked_keys.append(str(key).to_lower())
	_email_regex.compile("[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}")
	_ipv4_regex.compile("\\b(?:\\d{1,3}\\.){3}\\d{1,3}\\b")


func sanitize(value: Variant) -> Variant:
	match typeof(value):
		TYPE_DICTIONARY:
			var clean: Dictionary = {}
			for raw_key in value.keys():
				var key := str(raw_key)
				if _is_blocked_key(key):
					clean[key] = REDACTED_VALUE
				else:
					clean[key] = sanitize(value[raw_key])
			return clean
		TYPE_ARRAY:
			var out: Array = []
			for item in value:
				out.append(sanitize(item))
			return out
		TYPE_STRING:
			return _sanitize_string(value)
		_:
			return value


func _is_blocked_key(key: String) -> bool:
	var normalized := key.to_lower()
	for blocked in _blocked_keys:
		if normalized == blocked or normalized.contains(blocked):
			return true
	return false


func _sanitize_string(text: String) -> String:
	if _email_regex.search(text) != null:
		return REDACTED_VALUE
	if _ipv4_regex.search(text) != null:
		return REDACTED_VALUE
	if _looks_like_phone(text):
		return REDACTED_VALUE
	return text


func _looks_like_phone(text: String) -> bool:
	var digits := 0
	for i in text.length():
		var code := text.unicode_at(i)
		if code >= 48 and code <= 57:
			digits += 1
	return digits >= 7
