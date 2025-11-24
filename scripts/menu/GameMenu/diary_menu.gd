extends Control
var current_page = 0
var pages = []
@onready var header_left: Label = $Panel/Header
@onready var text_left: Label = $Panel/Text

@onready var header_right: Label = $Panel2/Header
@onready var text_right: Label = $Panel2/Text

@onready var prev_button: Button = $Panel/PrevButton
@onready var next_button: Button = $Panel2/NextButton

func _ready() -> void:
	pages = build_all_pages()
	update_pages()

func open_entries():
	pages = build_all_pages()
	current_page = 0
	update_pages()

func update_pages():
	header_left.text = pages[current_page]["header"]
	text_left.text = pages[current_page]["text"]
	
	if current_page + 1 < pages.size():
		header_right.text = pages[current_page + 1]["header"]
		text_right.text = pages[current_page +1]["text"]
		$Panel2.show()
	else:
		header_right.text = ""
		text_right.text = ""
		$Panel2.hide()
	prev_button.disabled = current_page == 0
	next_button.disabled = current_page + 2 >= pages.size()
	print(pages.size())
	print(current_page + 2)

func _split_into_pages(text: String, max_chars_per_page: int) -> Array[String]:
	var result: Array[String] = []
	var i: int = 0
	var length: int = text.length()
	while i < length:
		var end: int = min(i + max_chars_per_page, length)
		var slice_end: int = end
		if end < length:
			var last_space: int = text.rfind(" ", end - 1)
			if last_space >= i:
				slice_end = last_space + 1
		var part: String = text.substr(i, slice_end - i).strip_edges()
		result.append(part)
		i = slice_end
	if result.is_empty():
		result.append("")
	return result



func build_all_pages():
	var combined_pages = []
	var max_chars = 750
	
	for id in Diary.unlocked_entries:
		var header = Diary.get_header(id)
		var full_text = Diary.get_text(id)
		var auto_pages = _split_into_pages(full_text, max_chars)
		for p in auto_pages:
			combined_pages.append({
				"header": header,
				"text": p
			})
	
	return combined_pages

func _on_prev_button_pressed() -> void:
	if current_page - 2 >= 0:
		current_page -= 2
		update_pages()


func _on_next_button_pressed() -> void:
	if current_page + 2 < pages.size():
		current_page += 2
		update_pages()


func _on_close_button_pressed() -> void:
	get_tree().paused = false
	GameMenu.hide()
	GlobalMenuButton.show()
	SettingsButton.show()
