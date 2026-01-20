extends Control

@onready var tutorial_title := $TextureRect/Tutorial_Title
@onready var tutorial_text := $TextureRect/Tutorial_Text

enum TutorialStep {
	MOVEMENT,
	SPRINT,
	INTERACT,
	DONE
}

var current_step := TutorialStep.MOVEMENT

var movement_counter := 0
var used_movement := {
	"moveLeft": false,
	"moveRight": false,
	"moveUp": false,
	"moveDown": false
}
func _ready():
	if GameState.tutorial_done:
		visible = false
		set_process_input(false)
		return

	_update_text()

func start_tutorial():
	tutorial_title.text = "Controls"
	visible = true
	current_step = TutorialStep.MOVEMENT
	_update_text()

func _input(event):
	match current_step:
		TutorialStep.MOVEMENT:
			_check_movement(event)
		TutorialStep.SPRINT:
			_check_sprint(event)
		TutorialStep.INTERACT:
			_check_interact(event)

func _check_movement(event):
	for action in used_movement.keys():
		if not used_movement[action] and event.is_action_pressed(action):
			SfxPlayer.notification_sound()
			used_movement[action] = true
			movement_counter += 1
			_update_text()

	if movement_counter >= 4:
		current_step = TutorialStep.SPRINT
		_update_text()

func _check_sprint(event):
	if event.is_action_pressed("run"):
		SfxPlayer.notification_sound()
		current_step = TutorialStep.INTERACT
		_update_text()

func _check_interact(event):
	if event.is_action_pressed("interact"):
		SfxPlayer.notification_sound()
		current_step = TutorialStep.DONE
		_update_text()
		visible = false
		set_process_input(false)

		GameState.tutorial_done = true
		SaveSystem.save_game()

func _update_text():
	if GameState.language == "en":
		match current_step:
			TutorialStep.MOVEMENT:
				tutorial_title.text = "MOVEMENT"
				tutorial_text.text = "Use WASD to move (%d/4)" % movement_counter
			TutorialStep.SPRINT:
				tutorial_title.text = "SPRINTING"
				tutorial_text.text = "Hold Shift to sprint"
			TutorialStep.INTERACT:
				tutorial_title.text = "INTERACT"
				tutorial_text.text = "Press E to interact"
				
	else:
		match current_step:
			TutorialStep.MOVEMENT:
				tutorial_title.text = "BEWEGUNG"
				tutorial_text.text = "Benutze WASD zum Steuern (%d/4)" % movement_counter
			TutorialStep.SPRINT:
				tutorial_title.text = "RENNEN"
				tutorial_text.text = "Halte Shift um zu rennen"
			TutorialStep.INTERACT:
				tutorial_title.text = "INTERAGIEREN"
				tutorial_text.text = "Drücke E zum Interagieren"
