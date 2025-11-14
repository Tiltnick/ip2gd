extends NPCState
class_name NPCIdle

# Idle anim
func Enter(_prev: NPCState) -> void:
	if npc.anim:
		npc.anim.play("idle")

# Geschwindigkeit auf 0 | Physik für Kollision
func PhysicsUpdate(_delta: float) -> void:
	npc.velocity = Vector2.ZERO
	npc.move_and_slide()

# Transition wenn Player nicht near in npc.gd
	if not npc.is_player_near():
		TransitionTo("move")
