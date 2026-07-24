extends WrappableCharacter

@export var acceleration := 12.0
@export var max_speed := 400.0

func _physics_process(delta):
	var input_vector := Vector2(Input.get_axis("move_left","move_right"),Input.get_axis("move_up","move_down"))
	velocity += input_vector*acceleration
	velocity=velocity.limit_length(max_speed)
	velocity=velocity.lerp(Vector2(0,0),0.02)
	move_and_slide()
