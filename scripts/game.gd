extends Node3D

@onready var lasers = $lasers
@onready var enemies = $enemies
@onready var player = $player
@onready var enemy1 = preload("res://scenes/enemy_1.tscn")
@onready var turretbombs = $turretbombs
@onready var turretbombscene = preload("res://scenes/turretbomb.tscn")
@export var max_enemies = 3


func _ready():
	spawn_enemy1()
	
func _on_turret_laser_shot(laser, gp, gr):
	lasers.add_child(laser)   # must be in tree before setting global_*
	laser.global_rotation = gr
	laser.global_position = gp   # gp is already the muzzle position
	laser.direction = Vector3(cos(gr.z), sin(gr.z), 0)
	
func _process(_delta):
	pass
	
func spawn_enemy1():
	while true:
		await enemies.get_tree().create_timer(5).timeout
		if enemies.get_child_count() < max_enemies:
			var enemy = enemy1.instantiate()
			var gp: Vector3
			var redo = true
			while redo:
				gp = Vector3(randf_range(-7,7),randf_range(-4,4),0)
				if gp.distance_to(player.global_position) > 1:
					redo = false
				else:
					continue
				for i in enemies.get_children():
					if gp.distance_to(i.global_position) < 1:
						redo = true
						break
			enemies.add_child(enemy)
			enemy.turret.laser_shot.connect(_on_turret_laser_shot)   # spawned enemies aren't editor-wired
			enemy.global_position = gp


func _on_player_throw_turret(zrotation: float, pos: Vector3):
	var tb = turretbombscene.instantiate()
	turretbombs.add_child(tb)
	tb.rotate(Vector3(0,0,1),zrotation)
	tb.global_position = pos
	tb.scale=Vector3(0.4,0.4,0.4)
	tb.velocity=Vector3(5,0,0).rotated(Vector3(0,0,1),zrotation)
	tb.move_and_slide()

func boom(pos):
	pass

func _on_countdown_timeout():
	if player.has_turret:
		boom(player.global_position)
	else:
		var tbomblocation: Vector3
		for i in turretbombs.get_children():
			if i is tbomb:
				tbomblocation=i.global_position
		boom(tbomblocation)
