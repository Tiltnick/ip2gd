extends State
class_name idle

@export var sprite : AnimatedSprite2D

func Enter():
	spirte.play("Idle")
	pass
	
func Update(_delta: float):
if(Input.get_vector("moveLeft", "moveRight", "moveUp", "moveDown")):
	
