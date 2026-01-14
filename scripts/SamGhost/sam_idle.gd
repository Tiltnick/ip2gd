extends SamState
class_name SamIdle


func Enter(_prev: SamState) -> void:
	if npc.anim:
		npc.anim.play("idle")


func PhysicsUpdate(_delta: float) -> void:
	npc.velocity = Vector2.ZERO
	npc.move_and_slide()
