extends VBoxContainer
@onready var button_musicL: Button = $HBoxContainer/Button_MusicL
@onready var button_musicM: Button = $HBoxContainer/Button_MusicM
@onready var button_soundL: Button = $HBoxContainer2/Button_SoundL
@onready var button_soundM: Button = $HBoxContainer2/Button_SoundM
@onready var slider_music: HSlider = $HBoxContainer/HSlider_Music
@onready var slider_sound: HSlider = $HBoxContainer2/HSlider_Sound


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



func _on_button_music_l_pressed() -> void:
	button_musicL.hide()
	button_musicM.show()
	slider_music.value = 0


func _on_button_music_m_pressed() -> void:
	button_musicL.show()
	button_musicM.hide()
	slider_music.value = 50


func _on_button_sound_l_pressed() -> void:
	button_soundL.hide()
	button_soundM.show()
	slider_sound.value = 0


func _on_button_sound_m_pressed() -> void:
	button_soundL.show()
	button_soundM.hide()
	slider_sound.value = 50


func _on_h_slider_2_value_changed(value: float) -> void:
	if value == 0:
		button_soundL.hide()
		button_soundM.show()
	else:
		button_soundL.show()
		button_soundM.hide()


func _on_h_slider_value_changed(value: float) -> void:
	if value == 0:
		button_musicL.hide()
		button_musicM.show()
	else:
		button_musicL.show()
		button_musicM.hide()
