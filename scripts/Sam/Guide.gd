extends Node

var npc
var sm

@export var point_spacing: float = 16.0
@export var reach_radius: float = 10.0
@export var start_delay: float = 0.25

var points: PackedVector2Array = []
var index: int = 0
var _completed: bool = false


func setup(_npc, _sm) -> void:
	npc = _npc
	sm = _sm


func enter() -> void:
	_completed = false

	if npc.guide_path_node == null:
		sm.transition_to("WaitInteract")
		return

	npc.guide_started.emit()
	npc.take_camera()

	points = _sample_path(npc.guide_path_node)
	index = 0

	if start_delay > 0.0:
		await npc.get_tree().create_timer(start_delay).timeout


func physics_update(_delta: float) -> void:
	if _completed:
		return

	if points.is_empty():
		_finish()
		return

	var target: Vector2 = points[index]
	npc.move_towards(target)

	if npc.global_position.distance_to(target) <= reach_radius:
		index += 1
		if index >= points.size():
			_finish()


func _finish() -> void:
	_completed = true

	npc.velocity = Vector2.ZERO
	npc.move_and_slide()

	npc.restore_camera()
	npc.guide_finished.emit()

	# Nach dem Zeigen: SAM soll warten (Spieler läuft selbst)
	if npc.has_method("on_guide_completed"):
		npc.call_deferred("on_guide_completed")


func _sample_path(path: Path2D) -> PackedVector2Array:
	var baked: PackedVector2Array = path.curve.get_baked_points()
	if baked.is_empty():
		return PackedVector2Array()

	var out := PackedVector2Array()
	out.append(path.to_global(baked[0]))

	var acc := 0.0
	for i in range(1, baked.size()):
		var a := baked[i - 1]
		var b := baked[i]
		acc += a.distance_to(b)

		if acc >= point_spacing:
			acc = 0.0
			out.append(path.to_global(b))

	return out


func exit() -> void:
	if not _completed:
		npc.restore_camera()
		npc.guide_finished.emit()
