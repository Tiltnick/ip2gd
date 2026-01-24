extends CanvasLayer

@onready var mini_map: CanvasLayer = $"."
@onready var map_texture: TextureRect = $MapTexture
@onready var marker_outside_1: TextureRect = $Marker/Marker_Outside1
@onready var marker_outside_2: TextureRect = $Marker/Marker_Outside2
@onready var marker_outside_3: TextureRect = $Marker/Marker_Outside3
@onready var marker_outside_4: TextureRect = $Marker/Marker_Outside4
@onready var marker_spaceship: TextureRect = $Marker/Marker_Spaceship
@onready var markers: Node = $Marker
@onready var panel: Panel = $Panel
@onready var label: Label = $Panel/Label
@onready var building: TextureRect = $Building
@onready var oris_shuttle: TextureRect = $Oris_Shuttle
@onready var sam_shuttle: TextureRect = $Sam_Shuttle
@onready var stone_panel: TextureRect = $Stone_Panel
@onready var temple: TextureRect = $Temple
@onready var tower: TextureRect = $Tower
@onready var sockets: TextureRect = $Sockets

func _ready() -> void:
	pass

func map_interact():
	if mini_map.visible:
		close_map()
		return
	else:
		open_map()
		return

func open_map():
	var scene: Node = get_tree().current_scene
	var scene_name: String = String(scene.name) if scene != null else ""
	map_texture.texture = _get_map_texture()
	update_marker(scene_name)
	mini_map.show()

func close_map():
	for marker in markers.get_children():
		marker.hide()
	mini_map.hide()

func _get_map_texture() -> Texture2D:
	var outside_2 = GameState.map_state.get("outside2_map", false)
	var outside_3 = GameState.map_state.get("outside3_map", false)
	var outside_4 = GameState.map_state.get("outside4_map", false)

	if outside_4:
		building.show()
		oris_shuttle.show()
		sam_shuttle.show()
		stone_panel.show()
		temple.show()
		tower.show()
		sockets.show()
		return preload("res://assets/sprites/selfmade/map/WholeMap.png")

	if outside_3:
		building.show()
		oris_shuttle.show()
		sam_shuttle.show()
		stone_panel.show()
		tower.show()
		sockets.show()
		return preload("res://assets/sprites/selfmade/map/minimap_3.png")

	if outside_2:
		building.show()
		oris_shuttle.show()
		sam_shuttle.show()
		tower.show()
		return preload("res://assets/sprites/selfmade/map/minimap_2.png")

	# Fallback
	return preload("res://assets/sprites/selfmade/map/minimap_1.png")

func update_marker(scene_name: String) -> void:
	match scene_name:
		"Spaceship":
			marker_spaceship.show()
		"Outside1":
			marker_outside_1.show()
		"Outside2":
			marker_outside_2.show()
		"Outside3":
			marker_outside_3.show()
		"Outside4":
			marker_outside_4.show()

func show_tooltip(text: String, _pos: Vector2):
	label.text = text
	panel.visible = true
	#panel.global_position = pos + Vector2(18, -10)

func hide_tooltip():
	panel.visible = false


func _on_close_button_pressed() -> void:
	close_map()
