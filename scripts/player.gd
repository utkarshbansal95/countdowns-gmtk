class_name player extends WrappableCharacter

signal throw_turret(zrotation, pos)
signal health_changed(current)

@export var acceleration := 40
@export var max_speed := 8.0
@export var damping := 3.0
@export var using_mouse := true
@export var rotation_speed := 0.1
@export var has_turret := true
@export var max_health := 10
@export var turn_speed := 12.0        # how fast the mesh swings to a new heading
@export var mesh_angle_offset := 0.0  # degrees, in case the model's nose isn't local +Y

@onready var mesh: Node3D = $Low_Poly_Spaceship_0052
@onready var mesh_scale: Vector3 = mesh.scale      # the basis rebuild in _tilt_mesh wipes the 0.1 scale otherwise
@onready var mesh_pivot: Vector3 = mesh.position   # the ship spins about this, not about the player origin
@onready var justthrown = $justthrown
@onready var health := max_health
@onready var player_turret_scene = preload("res://scenes/turretequipped.tscn")

var just_thrown = false
var turret: Turret   # filled by draw_turret(), no longer a scene child
var face_angle := 0.0

const TURRET_MOUNT := Vector3(-0.005, 0.16, 0.2)   # where the gun sits at face_angle 0

func _ready():
	draw_turret()

func _physics_process(delta):
	var input_vector := Vector3(Input.get_axis("move_left","move_right"),Input.get_axis("move_down","move_up"),0.0) #move up and down swapped as 3d y axis is normal

	velocity += input_vector*acceleration*delta
	velocity=velocity.limit_length(max_speed)
	velocity=velocity.lerp(Vector3(0,0,0),damping*delta)

	_tilt_mesh(input_vector, delta)

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
	
# Only the mesh turns, not the body - the collision shape and the body's own transform stay put
func _tilt_mesh(input_vector: Vector3, delta: float) -> void:
	if input_vector.length_squared() > 0.01:
		var target_angle := atan2(input_vector.y, input_vector.x) - PI/2 + deg_to_rad(mesh_angle_offset)
		face_angle = lerp_angle(face_angle, target_angle, turn_speed * delta)

	mesh.transform.basis = Basis(Vector3.BACK, face_angle).scaled(mesh_scale)

	if turret:
		turret.position = _turret_mount_pos()

# swung about the mesh's pivot, not the player origin, or the gun drifts off the hull
func _turret_mount_pos() -> Vector3:
	return mesh_pivot + Basis(Vector3.BACK, face_angle) * (TURRET_MOUNT - mesh_pivot)

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
	turret.position = _turret_mount_pos()
	var g := get_parent()   # replaces the editor wire, which can't survive a runtime turret
	if g and g.has_method("_on_turret_laser_shot"):
		turret.laser_shot.connect(g._on_turret_laser_shot)

func damage(dmg = 1):
	health -= dmg
	emit_signal("health_changed", health)   # before die() so the bar empties on the last hit
	if health <= 0:
		die()

func die():
	get_tree().call_deferred("change_scene_to_file", "res://scenes/game_over.tscn")


func _on_justthrown_timeout():
	just_thrown = false
