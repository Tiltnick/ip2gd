extends Node2D
class_name ViewAllPiecesHB

@export var spawned_from_hotbar: bool = false
@export var hotbar_scale: Vector2 = Vector2(0.5, 0.5)
@export var zoom_multiplier: float = 7.0
@export var spacing: float = 90.0
@export var piece_prefix: String = "stone_piece_"

@onready var pieces_container: Node2D = $PiecesContainer

@export var piece_scale: Vector2 = Vector2(0.25, 0.25)
@export var extra_gap: float = 20.0

var is_zoomed := false
var start_scale: Vector2

func _ready() -> void:
	start_scale = scale

func hotbar_activate():
	spawned_from_hotbar = true

	# echte Screen-Mitte -> World-Position
	var vp := get_viewport()
	var screen_center := vp.get_visible_rect().size * 0.5
	global_position = vp.get_canvas_transform().affine_inverse() * screen_center

	scale = hotbar_scale
	start_scale = scale
	z_index = 100

	_build_row()
	_zoom_in()

func interact() -> void:
	SfxPlayer.ui_click_sound()

	if not is_zoomed:
		_zoom_in()
	else:
		queue_free()

func _zoom_in():
	is_zoomed = true
	var t := create_tween()
	t.tween_property(self, "scale", start_scale * zoom_multiplier, 0.2)

func _build_row():
	for c in pieces_container.get_children():
		c.queue_free()

	var piece_ids: Array[String] = []
	for id in hotbarglobal.inventory_items:
		if id != null:
			var s := String(id)
			if s.begins_with(piece_prefix):
				piece_ids.append(s)

	piece_ids.sort()

	var textures: Array[Texture2D] = []
	var widths: Array[float] = []

	for pid in piece_ids:
		if not ItemDatabase.DATA.has(pid):
			continue
		var path: String = ItemDatabase.DATA[pid].get("icon", "")
		if path == "" or not ResourceLoader.exists(path):
			continue

		var tex: Texture2D = load(path)
		textures.append(tex)
		widths.append(float(tex.get_width()) * piece_scale.x)

	var count := textures.size()
	if count == 0:
		return

	var total_width := 0.0
	for w in widths:
		total_width += w
	total_width += float(count - 1) * extra_gap

	var x := -total_width * 0.5

	for i in range(count):
		var spr := Sprite2D.new()
		spr.texture = textures[i]
		spr.scale = piece_scale
		spr.position = Vector2(x + widths[i] * 0.5, 0)
		pieces_container.add_child(spr)

		x += widths[i] + extra_gap

	pieces_container.position = Vector2.ZERO
