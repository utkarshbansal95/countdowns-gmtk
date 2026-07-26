extends WrappableCharacter

@export var speed := 2.0
@export var enemy_rate_of_fire := 1.0
@export var enemy_laser_color := Color.RED
@export var max_health = 5

@onready var health = max_health
@onready var turret: Turret = $turret

var target: Node3D

func _ready():
	spawn() #spawn animation and initial wait
	target = get_tree().get_first_node_in_group("player")
	turret.rate_of_fire = enemy_rate_of_fire
	turret.laser_color = enemy_laser_color

func _physics_process(_delta):
	if target:
		var dir := target.global_position - global_position
		dir.z = 0
		velocity = dir.normalized() * speed
	if target:
		turret.aim_at(target.global_position)
		turret.try_fire()
	move_and_slide()
	

func spawn():
	pass

func damage(dmg = 1):   # Animation/sfx for taking damage (Here or maybe on type of damage)
	health -= dmg
	if health <= 0:
		die()

func die():   # Animation to be added for death here if I have time
	queue_free()
