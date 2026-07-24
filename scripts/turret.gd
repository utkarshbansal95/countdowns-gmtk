extends WrappableCharacter

@export var rotation_speed := 0.1
@export var using_mouse := true

func _ready():
	pass

func _process(delta):
	if using_mouse:
		rotation=(get_global_mouse_position()-global_position).angle()+deg_to_rad(90.0)
	else:
		if Input.is_action_pressed("clockwise"):
			rotate(rotation_speed)
		if Input.is_action_pressed("counterclockwise"):
			rotate(-rotation_speed)
