extends CharacterBody3D

@export var rotation_speed := 0.1
@export var using_mouse := true

func _ready():
	pass

func _process(delta):
	if using_mouse:
		#rotation.z=(get_global_mouse_position()-global_position).angle()+deg_to_rad(90.0)
		var target := _mouse_on_play_plane()
		var dir := target - global_position   # vector from turret to the mouse, world space
		# atan2 gives the angle of 'dir' from +X, counter-clockwise positive.
		# Subtract 90° because the barrel points +Y (up) at rotation 0.
		# If the barrel aims the wrong way, flip this sign or add PI to tune it.
		rotation.z = atan2(dir.y, dir.x) - PI / 2.0
	else:
		if Input.is_action_pressed("clockwise"):
			rotate_z(-rotation_speed)
		if Input.is_action_pressed("counterclockwise"):
			rotate_z(rotation_speed)

#Pre-defined function from the internet for a 3d get global mouse position
func _mouse_on_play_plane() -> Vector3:
	var cam := get_viewport().get_camera_3d()
	var mouse := get_viewport().get_mouse_position()
	var ray_origin := cam.project_ray_origin(mouse)   # a world-space point on the ray
	var ray_dir := cam.project_ray_normal(mouse)      # the ray's world-space direction
	# Solve ray_origin.z + t * ray_dir.z = 0  ->  t = -ray_origin.z / ray_dir.z
	var t := -ray_origin.z / ray_dir.z
	return ray_origin + ray_dir * t
