extends WrappableCharacter

@export var acceleration := 40
@export var max_speed := 8.0
@export var damping := 3.0

var has_turret := true

func _physics_process(delta):
	var input_vector := Vector3(Input.get_axis("move_left","move_right"),Input.get_axis("move_down","move_up"),0.0) #move up and down swapped as 3d y axis is normal
	
	velocity += input_vector*acceleration*delta
	velocity=velocity.limit_length(max_speed)
	velocity=velocity.lerp(Vector3(0,0,0),damping*delta)
	
	move_and_slide()
