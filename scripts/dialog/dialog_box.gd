extends Control

# Node refs (match your current scene tree)
@onready var portrait: TextureRect      = $NinePatchRect/Portrait
@onready var name_label: Label          = $NinePatchRect/Name
@onready var choices: Control           = $NinePatchRect/Choices
@onready var dialog_text: RichTextLabel = $NinePatchRect/Dialog

# Typing config + state
@export var typing_speed := 0.02  # seconds between characters
var typing := false               # true while the page is animating
var skip := false                 # set to true to reveal the whole page at once

# Pagination state
var _pages: Array[String] = []    # text split into pages that fit the box
var _page_index := 0              # current page 

func _ready() -> void:

	dialog_text.scroll_active = false  # no scroll; we page instead

	hide()

	# Quick tedt
	show_dialog(
		"NPC",
		null,
		"Hello, this is a long test text. It should paginate across multiple pages if the box is too small. Keep pressing Enter to advance. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent commodo cursus magna, vel scelerisque nisl consectetur et. Donec sed odio dui. Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor."
	)

func show_dialog(charakter_name: String = "", portrait_texture: Texture2D = null, text: String = "") -> void:
	# Name: hide label if empty, otherwise show and set
	if charakter_name == "":
		name_label.hide()
	else:
		name_label.text = charakter_name
		name_label.show()

	# Portrait: hide if null, otherwise set texture and show
	if portrait_texture == null:
		portrait.hide()
	else:
		portrait.texture = portrait_texture
		portrait.show()

	

	# Build pages from the full text, then start typing the first page
	_page_index = 0
	_pages = await _paginate_text(text)
	if _pages.is_empty():
		type_text("")
	else:
		type_text(_pages[_page_index])
	show()

func type_text(text: String) -> void:
	# Set page text and start typewriter animation
	dialog_text.text = text
	dialog_text.visible_characters = 0
	typing = true
	skip = false

	var total := dialog_text.get_total_character_count()
	# Defer start by one frame 
	call_deferred("type_step", total)

func type_step(total: int) -> void:
	# Skip → reveal the whole page immediately
	if skip:
		dialog_text.visible_characters = total
		typing = false
		return

	# Still animating → add one character, wait a bit, and recurse
	if dialog_text.visible_characters < total:
		dialog_text.visible_characters += 1
		await get_tree().create_timer(typing_speed).timeout
		type_step(total)
	else:
		# Current page finished typing
		typing = false

func _unhandled_input(event: InputEvent) -> void:
	# Space (ui_accept):
	# - while typing → skip animation
	# - when finished → go to next page or end
	if event.is_action_pressed("ui_accept"):
		if typing:
			skip = true
		else:
			_show_next_page_or_finish()

func _show_next_page_or_finish() -> void:
	# Advance to next page if available, otherwise end 
	if _page_index + 1 < _pages.size():
		_page_index += 1
		type_text(_pages[_page_index])
	else:
		choices.visible = false
		hide()  

# Split a long string into page-sized chunks that fit the label’s height
func _paginate_text(full_text: String) -> Array[String]:
	var pages: Array[String] = []
	var start := 0
	var n := full_text.length()
	# Assumes: dialog_text has Word Autowrap and a fixed height
	dialog_text.scroll_active = false

	while start < n:
		var lo := 1
		var hi := n - start
		var best := 0

		# Binary search for the largest substring that still fits the box height
		while lo <= hi:
			var mid := (lo + hi) / 2
			var snippet := full_text.substr(start, mid)
			dialog_text.text = snippet

			# Wait a frame so get_content_height() matches the snippet we just set
			await get_tree().process_frame

			var content_h := dialog_text.get_content_height()
			var box_h := dialog_text.size.y

			if content_h <= box_h:
				best = mid
				lo = mid + 1
			else:
				hi = mid - 1

		if best <= 0:
			best = 1  # extremely small box fallback

		var end := start + best

		# Prefer cutting on a break character - see is_break_char which fall under that
		var cut := end
		# Try to move the end index backwards so we don't cut in the middle of a word.
		# We'll step backwards from 'end' until we hit a break character
		# (space, punctuation, newline, etc.).
		while cut > start and cut <= n:
			var idx := cut - 1
			var ch := full_text.substr(idx, 1)
			if _is_break_char(ch):
				break  # found a good split position
			cut -= 1

		# If we find a better split point, use it instead of the raw 'end'
		if cut > start:
			end = cut

		# Extract the substring for this page and trim leading/trailing spaces/newlines
		var page_text := full_text.substr(start, end - start).strip_edges(true, true)

		# Store the finished chunk in our list of pages
		pages.append(page_text)

		# Move the start pointer to the next unread part of the text
		start = end

	# Clean up: leave the label ready for the actual page to be set by type_text()
	dialog_text.text = ""
	return pages

# Basic set of characters that are safe break points for paging
func _is_break_char(ch: String) -> bool:
	return ch == " " or ch == "\n" or ch == "\t" or ch == "." or ch == "," or ch == "-" or ch == "!" or ch == "?" or ch == ";"
