extends Control

const SUPPORTED_LANGUAGES: Array[String] = ["automatic", "en", "de"]

@onready var option_button: OptionButton = $Panel/LanguagePanel/OptionButton
@onready var language_label: Label = $Panel/LanguagePanel/Label
@onready var controls_button: Button = $Panel/SideMenu/ControlsButton
@onready var language_button: Button = $Panel/SideMenu/LanguageButton
@onready var controls_panel: MarginContainer = $Panel/ControlsPanel
@onready var language_panel: HBoxContainer = $Panel/LanguagePanel

func _ready() -> void:
	_populate()
	_restore()

func _populate() -> void:
	option_button.clear()
	for code in SUPPORTED_LANGUAGES:
		option_button.add_item(code)

func _restore() -> void:
	var saved: String = LanguageManager.get_language()
	var idx: int = SUPPORTED_LANGUAGES.find(saved)
	if idx == -1:
		idx = 0
	option_button.select(idx)
	_update()

func _on_OptionButton_item_selected(index: int) -> void:
	var code: String = SUPPORTED_LANGUAGES[index]
	LanguageManager.set_language(code)
	_update()

func _update() -> void:
	language_label.text = tr("SETTINGS_LANGUAGE")
	controls_button.text = tr("UI_CONTROLS")
	language_button.text = tr("UI_OPTIONS")
	controls_panel.visible = false
	language_panel.visible = true

func _on_ControlsButton_pressed() -> void:
	controls_panel.visible = true
	language_panel.visible = false

func _on_LanguageButton_pressed() -> void:
	controls_panel.visible = false
	language_panel.visible = true

func _on_CloseButton_pressed() -> void:
	_close()

func _close() -> void:
	get_tree().paused = false
	GlobalMenuButton.show()
	SettingsButton.show()
	SettingsMenu.hide()
