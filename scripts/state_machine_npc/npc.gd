extends CharacterBody2D
class_name NPC

@export var move_speed: float = 50.0
@export var detect_radius: float = 120.0
@export var path_follow: PathFollow2D

@onready var anim: AnimatedSprite2D = $anim
@onready var outline: AnimatedSprite2D = $Outline
@onready var detect_area: Area2D = $DetectionArea
@onready var e_popup_node: Control = $Press_E_Popup_NPC

# Szene → Dialogdatei
const DIALOG_BY_SCENE := {
	"Outside1": "res://dialog/dialogueMrBlob/outside_1.json",
	"Outside2": "res://dialog/dialogueMrBlob/outside_2_part_1.json",
	
}

var player_inside := false
var player: Node2D = null

# Dialog neustarten verhindern
var dialog_active := false


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	
	outline.visible = false

	detect_area.body_entered.connect(_on_body_entered)
	detect_area.body_exited.connect(_on_body_exited)


func _process(_delta: float) -> void:
	outline.visible = player_inside

	if player_inside:
		outline.frame = anim.frame
		if not dialog_active and Input.is_action_just_pressed("interact"):
			
			# Popup ausblenden
			if e_popup_node:
				e_popup_node.visible = false

			# aktuelle szene rausfinden
			var scene: Node = get_tree().current_scene
			var scene_name: String = scene.name if scene != null else ""

			
			var dialog_path: String = ""

			if scene_name == "Outside2":
				if not GameState.puzzle_state.get("blob_intro_done", false):
					dialog_path = "res://dialog/dialogueMrBlob/outside_2_part_1.json"
				elif not GameState.puzzle_state.get("blob_clue_done", false):
					dialog_path = "res://dialog/dialogueMrBlob/clue_stone_pile.json"
				elif not GameState.puzzle_state.get("blob_revelation_done", false):
					dialog_path = "res://dialog/dialogueMrBlob/outside_2_part_2.json"
				else:
					dialog_path = "res://dialog/dialogueMrBlob/generic_hint.json"
			else:
				if DIALOG_BY_SCENE.has(scene_name):
					dialog_path = DIALOG_BY_SCENE[scene_name]
				else:
					dialog_path = "res://dialog/dialogueMrBlob/outside_1.json"


			if dialog_path != "":
				DialogManager.start_dialog(dialog_path)
				dialog_active = true



func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_inside = true
		outline.visible = true

		# Nur zeigen, wenn kein Dialog läuft
		if e_popup_node and not dialog_active:
			e_popup_node.visible = true


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		# Dialog schließen
		DialogManager.hide()

		player_inside = false
		outline.visible = false

		# Popup ausblenden
		if e_popup_node:
			e_popup_node.visible = false
		dialog_active = false
