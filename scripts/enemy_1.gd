extends WrappableCharacter


@export var acceleration := 40
@export var max_speed := 8.0
@export var damping := 3.0


func _physics_process(delta: float) -> void:
	
	

	move_and_slide()
