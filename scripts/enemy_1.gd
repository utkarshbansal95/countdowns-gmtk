class_name enemyclass extends WrappableCharacter

@export var max_speed := 2.0
@export var acceleration := 30.0
@export var enemy_rate_of_fire := 1.0
@export var enemy_laser_color := Color.RED
@export var max_health := 5
@export var max_distance_p := 6.0     #max distance it will try to get from player
@export var min_distance_p := 3.0      #obvious from above

@export var rotation_sp := 40   #Only for animation
@onready var ship_axis := Vector3 (0, sin (PI/3),cos (PI/3))

const BAR_OFFSET := Vector3(0, 0.7, 0.6)   # +z keeps it in front of the ufo mesh
const BAR_HALF_W := 0.4                    # half the fill quad's width

@onready var health := max_health
@onready var turret: Turret = $turret
@onready var spin := PI/2      #defines what direction the ship tends to spin by default
@onready var healthbar := $HealthBar
@onready var healthbar_fill := $HealthBar/Fill

var target: Node3D

func _ready():
	spawn() #spawn animation and initial wait
	target = get_tree().get_first_node_in_group("player")
	turret.rate_of_fire = enemy_rate_of_fire
	turret.laser_color = enemy_laser_color
	spin *= [-1, 1].pick_random()

func _physics_process(delta):
	#movement section
	if target:
		var dir := target.global_position - global_position
		dir.z = 0
		var tangent = dir.rotated(Vector3(0,0,1),spin)
		if dir.length() < min_distance_p:
			dir = -dir.normalized()
		elif dir.length() > max_distance_p:
			dir = dir.normalized()
		else:
			dir = Vector3(0,0,0)
		dir = tangent+dir
		dir = dir.normalized()
		velocity += dir*acceleration*delta
		velocity=velocity.limit_length(max_speed)
		var collision_info = move_and_collide(velocity * delta, true)
		if collision_info:
			if collision_info.get_collider().is_in_group("player"):   #group, not "is player" - that class ref cycles with player.gd
				velocity = velocity.bounce(collision_info.get_normal())
				damage()

	#aiming and firing section
	if target:
		turret.aim_at(target.global_position)
		turret.try_fire()
		
	#animation
	rotate(ship_axis, -spin*deg_to_rad(rotation_sp * delta))
	
	move_and_slide()
	

func _process(delta):
	super._process(delta)   # wrap first, then pin the bar to where we ended up
	healthbar.visible = health < max_health
	if not healthbar.visible:
		return
	healthbar.global_transform = Transform3D(Basis(), global_position + BAR_OFFSET)   # identity basis cancels the ship's spin
	var ratio := clampf(float(health) / max_health, 0.0, 1.0)
	healthbar_fill.scale.x = maxf(ratio, 0.001)
	healthbar_fill.position.x = -BAR_HALF_W * (1.0 - ratio)   # quad is centred, so pin the left edge

func spawn():
	pass

func damage(dmg = 1):   # Animation/sfx for taking damage (Here or maybe on type of damage)
	health -= dmg
	if health <= 0:
		die()

func die():   # Animation to be added for death here if I have time
	queue_free()
