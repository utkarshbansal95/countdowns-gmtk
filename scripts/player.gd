extends WrappableCharacter

signal throw_turret(zrotation, pos)

@export var acceleration := 40
@export var max_speed := 8.0
@export var damping := 3.0
@export var using_mouse := true
@export var rotation_speed := 0.1
@export var has_turret := true
@export var max_health := 10

@onready var justthrown = $justthrown
@onready var health := max_health
@onready var player_turret_scene = preload("res://scenes/turretequipped.tscn")

var just_thrown = false
var turret: Turret   # filled by draw_turret(), no longer a scene child

func _ready():
	draw_turret()

func _physics_process(delta):
	var input_vector := Vector3(Input.get_axis("move_left","move_right"),Input.get_axis("move_down","move_up"),0.0) #move up and down swapped as 3d y axis is normal

	velocity += input_vector*acceleration*delta
	velocity=velocity.limit_length(max_speed)
	velocity=velocity.lerp(Vector3(0,0,0),damping*delta)

	move_and_slide()
	
	var collision_info = move_and_collide(velocity * delta, true)
	if collision_info:
		if collision_info.get_collider() is enemyclass:
			velocity = velocity.bounce(collision_info.get_normal())
			damage()
		elif (collision_info.get_collider() is tbomb) and !just_thrown:
			collision_info.get_collider().queue_free()
			has_turret = true
			draw_turret()
			

func _process(delta):
	super._process(delta)   # keeps WrappableCharacter's screen wrap alive
	if not turret:
		return
	if using_mouse:
		turret.aim_at(_mouse_on_play_plane())
	else:
		if Input.is_action_pressed("clockwise"):
			turret.rotate_z(-rotation_speed)
		if Input.is_action_pressed("counterclockwise"):
			turret.rotate_z(rotation_speed)
	if Input.is_action_pressed("fire"):
		turret.try_fire()
	if Input.is_action_just_pressed("throw"):
		emit_signal ("throw_turret", turret.rotation.z,turret.global_position)
		turret.queue_free()
		has_turret = false
		just_thrown = true
		justthrown.start()
	
#Got from claude for a 3d get global mouse position
func _mouse_on_play_plane() -> Vector3:
	var cam := get_viewport().get_camera_3d()
	var mouse := get_viewport().get_mouse_position()
	var ray_origin := cam.project_ray_origin(mouse)   # a world-space point on the ray
	var ray_dir := cam.project_ray_normal(mouse)      # the ray's world-space direction
	# Solve ray_origin.z + t * ray_dir.z = 0  ->  t = -ray_origin.z / ray_dir.z
	var t := -ray_origin.z / ray_dir.z
	return ray_origin + ray_dir * t

func draw_turret():
	if not has_turret:
		return
	turret = player_turret_scene.instantiate()
	add_child(turret)
	turret.scale = Vector3(0.4,0.4,0.4)
	turret.position = Vector3(-0.005, 0.16, 0.2)
	var g := get_parent()   # replaces the editor wire, which can't survive a runtime turret
	if g and g.has_method("_on_turret_laser_shot"):
		turret.laser_shot.connect(g._on_turret_laser_shot)

func damage(dmg = 1):
	health -= dmg
	if health <= 0:
		die()

func die():
	get_tree().call_deferred("change_scene_to_file", "res://scenes/main_menu.tscn")


func _on_justthrown_timeout():
	just_thrown = false
