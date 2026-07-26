extends WrappableCharacter

@export var acceleration := 40
@export var max_speed := 8.0
@export var damping := 3.0
@export var using_mouse := true
@export var rotation_speed := 0.1

@onready var turret: Turret = $turret

func _physics_process(delta):
	var input_vector := Vector3(Input.get_axis("move_left","move_right"),Input.get_axis("move_down","move_up"),0.0) #move up and down swapped as 3d y axis is normal

	velocity += input_vector*acceleration*delta
	velocity=velocity.limit_length(max_speed)
	velocity=velocity.lerp(Vector3(0,0,0),damping*delta)

	move_and_slide()

func _process(_delta):
	super._process(_delta)   # keeps WrappableCharacter's screen wrap alive
	if using_mouse:
		turret.aim_at(_mouse_on_play_plane())
	else:
		if Input.is_action_pressed("clockwise"):
			turret.rotate_z(-rotation_speed)
		if Input.is_action_pressed("counterclockwise"):
			turret.rotate_z(rotation_speed)
	if Input.is_action_pressed("fire"):
		turret.try_fire()

#Got from claude for a 3d get global mouse position
func _mouse_on_play_plane() -> Vector3:
	var cam := get_viewport().get_camera_3d()
	var mouse := get_viewport().get_mouse_position()
	var ray_origin := cam.project_ray_origin(mouse)   # a world-space point on the ray
	var ray_dir := cam.project_ray_normal(mouse)      # the ray's world-space direction
	# Solve ray_origin.z + t * ray_dir.z = 0  ->  t = -ray_origin.z / ray_dir.z
	var t := -ray_origin.z / ray_dir.z
	return ray_origin + ray_dir * t
