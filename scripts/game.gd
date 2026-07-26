extends Node3D

@onready var lasers = $lasers
@onready var enemies = $enemies
@onready var player = $player
@onready var enemy1 = preload("res://scenes/enemy_1.tscn")

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
		if enemies.get_child_count() < 5:
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
			enemy.global_position = gp
