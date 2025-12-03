extends Area2D

func _on_body_entered(body):
	if body is MainCharacter:
		var parent = self.get_parent()
		if parent:
			parent.modulate.a = 0.1

func _on_body_exited(body):
	if body is MainCharacter:
		var parent = self.get_parent()
		if parent:
				parent.modulate.a = 1
