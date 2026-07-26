class_name Turret extends CharacterBody3D

signal laser_shot(laser, position, rotation)

@export var rate_of_fire = 0.2
@export var laser_color := Color(0.3, 0.6, 1.0)

var laser_scene = preload("res://scenes/laser.tscn")
var shoot_cooldown = false

@onready var muzzle: Marker3D = $Muzzle

func aim_at(world_pos: Vector3) -> void:
	var dir := world_pos - global_position
	global_rotation = Vector3(0, 0, atan2(dir.y, dir.x))   # global, so a rotating parent can't skew the aim

func try_fire() -> void:
	if shoot_cooldown:
		return
	shoot_cooldown = true
	shoot_laser()
	await get_tree().create_timer(rate_of_fire).timeout
	shoot_cooldown = false

func shoot_laser():
	var l = laser_scene.instantiate()
	l.color = laser_color
	l.shooter = get_parent()
	var d := muzzle.global_position - global_position
	var ang := atan2(d.y, d.x)   # from world positions, so scale sign can't flip it
	emit_signal("laser_shot", l, muzzle.global_position, Vector3(0,0,ang))
