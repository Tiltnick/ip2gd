extends GhostState
class_name GhostIdle

func Enter(_prev: GhostState) -> void:
	if ghost.anim:
		ghost.anim.play("idle")

func PhysicsUpdate(_delta: float) -> void:
	ghost.velocity = Vector2.ZERO
	ghost.move_and_slide()
