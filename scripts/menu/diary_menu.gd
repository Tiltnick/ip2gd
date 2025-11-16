extends Control
#var current_entry_id = ""
var current_page = 0
#var pages: Array = []
#var entry_header = ""
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
	header_left.text = pages[current_page].header
	text_left.text = pages[current_page].text
	
	if current_page + 1 < pages.size():
		header_right.text = pages[current_page + 1].header
		text_right.text = pages[current_page +1].text
		$Panel2.show()
	else:
		header_right.text = ""
		text_right.text = ""
		$Panel2.hide()
	prev_button.disabled = current_page == 0
	next_button.disabled = current_page + 2 > pages.size()


func build_all_pages():
	var combined_pages = []
	
	for id in Diary.unlocked_entries:
		var header = Diary.get_header(id)
		var pages = Diary.get_pages(id)
		for p in pages:
			combined_pages.append({
			"header": header,
			"text": p
		})
	return combined_pages




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_prev_button_pressed() -> void:
	if current_page - 2 >= 0:
		current_page -= 2
		update_pages()


func _on_next_button_pressed() -> void:
	if current_page + 2 < pages.size():
		current_page += 2
		update_pages()
