extends Node3D

@onready var lasers = $lasers
@onready var enemies = $enemies
@onready var player = $player
@onready var enemy1 = preload("res://scenes/enemy_1.tscn")

func _ready():
	spawn_enemy1()
	
func _on_turret_laser_shot(laser, gp, gr):
	lasers.add_child(laser)                                   # 1) add to the tree FIRST
	laser.global_rotation = gr                               # 2) now global_* is valid
	laser.global_position = gp + Vector3(0.6,0,0).rotated(Vector3(0,0,1),gr.z)
	laser.direction = Vector3(cos(gr.z), sin(gr.z), 0)       # 3) cache heading once, after it's placed
	
func _process(_delta):
	pass
	
func spawn_enemy1():
	while true:
		await enemies.get_tree().create_timer(5).timeout
		if enemies.get_child_count() < 5:
			var enemy = enemy1.instantiate()
			enemies.add_child(enemy)
			var gp = Vector3(randf_range(-7,7),randf_range(-4,4),0)
			while gp.distance_to(player.global_position) < 1:
				gp = Vector3(randf_range(-7,7),randf_range(-4,4),0)
			enemy.global_position = gp
