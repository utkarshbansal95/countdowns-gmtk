extends Node3D

@onready var lasers = $lasers

func _ready():
	pass
	
func _on_turret_laser_shot(laser, gp, gr):
	lasers.add_child(laser)                                   # 1) add to the tree FIRST
	laser.global_rotation = gr                               # 2) now global_* is valid
	laser.global_position = gp + Vector3(0.6,0,0).rotated(Vector3(0,0,1),gr.z)
	laser.direction = Vector3(cos(gr.z), sin(gr.z), 0)       # 3) cache heading once, after it's placed
	
func _process(_delta):
	pass
