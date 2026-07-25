extends Node3D

@onready var lasers = $lasers

func _ready():
	pass
	
func _on_turret_laser_shot(laser, gp, gr):
	laser.global_rotation=gr
	lasers.add_child(laser)
	laser.global_position=gp + Vector3(0.6,0,0).rotated(Vector3(0,0,1),gr.z)
	
func _process(_delta):
	pass
