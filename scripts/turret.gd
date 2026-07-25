class_name Turret extends CharacterBody3D

signal laser_shot(laser)

@export var rotation_speed = 0.1
@export var using_mouse = true
@export var rate_of_fire = 0.2

var laser_scene = preload("res://scenes/laser.tscn")
var shoot_cooldown = false

func _ready():
	pass

func _process(_delta):
	if using_mouse:
		var dir := _get_aim_target() - global_position   
		rotation.z = atan2(dir.y, dir.x)
	else:
		if Input.is_action_pressed("clockwise"):
			rotate_z(-rotation_speed)
		if Input.is_action_pressed("counterclockwise"):
			rotate_z(rotation_speed)
	if Input.is_action_pressed("fire"):
		if !shoot_cooldown:
			shoot_cooldown = true
			shoot_laser()
			await get_tree().create_timer(rate_of_fire).timeout
			shoot_cooldown = false

func _get_aim_target() -> Vector3:
	return _mouse_on_play_plane()    #defined below. Gets the vector of mouse from origin

#Got from claude for a 3d get global mouse position
func _mouse_on_play_plane() -> Vector3:
	var cam := get_viewport().get_camera_3d()
	var mouse := get_viewport().get_mouse_position()
	var ray_origin := cam.project_ray_origin(mouse)   # a world-space point on the ray
	var ray_dir := cam.project_ray_normal(mouse)      # the ray's world-space direction
	# Solve ray_origin.z + t * ray_dir.z = 0  ->  t = -ray_origin.z / ray_dir.z
	var t := -ray_origin.z / ray_dir.z
	return ray_origin + ray_dir * t

func shoot_laser():
	var l = laser_scene.instantiate()
	emit_signal("laser_shot", l, global_position, global_rotation)
