extends Control
var current_entry_id = ""
var current_page = 0
var pages: Array = []
var entry_header = ""

@onready var header_left: Label = $Panel/Header
@onready var text_left: Label = $Panel/Text

@onready var header_right: Label = $Panel2/Header
@onready var text_right: Label = $Panel2/Text

@onready var prev_button: Button = $Panel/PrevButton
@onready var next_button: Button = $Panel2/NextButton

func open_entry(id: String):
	if not Diary.is_unlocked(id):
		return
	current_entry_id = id
	pages = Diary.get_pages(id)
	entry_header = Diary.get_header(id)
	current_page = 0
	update_pages()

func update_pages():
	header_left.text = entry_header
	text_left.text = pages[current_page]
	
	if current_page + 1 < pages.size():
		header_right.text = entry_header
		text_right.text = pages[current_page +1]
		$Panel2.show()
	else:
		header_right.text = ""
		text_right.text = ""
		$Panel2.hide()
	prev_button.disabled = current_page == 0
	next_button.disabled = current_page + 2 > pages.size()



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_prev_button_pressed() -> void:
	if current_page - 2 >= 0:
		current_page -= 2
		update_pages()


func _on_next_button_pressed() -> void:
	pass # Replace with function body.
