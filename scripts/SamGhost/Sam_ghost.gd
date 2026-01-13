extends CharacterBody2D
class_name SamGhost

@export var move_speed: float = 120.0
@export var path_follow: PathFollow2D

# Dein DialogManager (CanvasLayer) – kann im Inspector gesetzt werden (z.B. Autoload-Instanz)
@export var dialog_runner: Node
# Flow/Flags Logik: gibt JSON-Pfad je Szene zurück
@export var dialog_process: SamDialogProcess

@onready var anim: AnimatedSprite2D = $anim
@onready var outline: AnimatedSprite2D = $outline # <- wichtig: Node heißt bei dir "outline" klein
@onready var detection_area: Area2D = $DetectionArea
@onready var state_machine: GhostStateMachine = $stateMachine

var player_inside: bool = false
var _interaction_locked: bool = false

func _ready() -> void:
	# Ghost Look (optional)
	if outline:
		outline.visible = false
	if anim:
		anim.modulate.a = 0.75

	# Player proximity
	if detection_area:
		detection_area.body_entered.connect(_on_body_entered)
		detection_area.body_exited.connect(_on_body_exited)

func _unhandled_input(event: InputEvent) -> void:
	if _interaction_locked:
		return
	if not player_inside:
		return

	if event.is_action_pressed("ui_accept"):
		_interaction_locked = true
		state_machine.request_transition("dialog")

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_inside = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_inside = false

func unlock_interaction() -> void:
	_interaction_locked = false
