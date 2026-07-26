class_name tbomb extends WrappableCharacter

func _ready() -> void:
	pass
	
func _physics_process(_delta):
	velocity=velocity.lerp(Vector3(0,0,0), 0.01)
	move_and_slide()
