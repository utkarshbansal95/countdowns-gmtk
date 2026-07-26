extends Node3D

@onready var lasers = $lasers

func _on_turret_laser_shot(laser, gp, gr):
	lasers.add_child(laser)   # must be in tree before setting global_*
	laser.global_rotation = gr
	laser.global_position = gp
	laser.direction = Vector3(cos(gr.z), sin(gr.z), 0)
