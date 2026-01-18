extends Control

@onready var tutorial_title := $TextureRect/Tutorial_Title
@onready var tutorial_text := $TextureRect/Tutorial_Text
@export var tutorial_id := "tutorial_seen_v1"

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
	if GameState.puzzle_state.get(tutorial_id, false) == true:
		visible = false
		set_process_input(false)
		return
	
	tutorial_title.text = "Steuerung"
	_update_text()

func start_tutorial():
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

		GameState.puzzle_state[tutorial_id] = true
		SaveSystem.save_game()

func _update_text():
	match current_step:
		TutorialStep.MOVEMENT:
			tutorial_text.text = "Use WASD to move (%d/4)" % movement_counter
		TutorialStep.SPRINT:
			tutorial_text.text = "Hold Shift to sprint"
		TutorialStep.INTERACT:
			tutorial_text.text = "Press E to interact"
