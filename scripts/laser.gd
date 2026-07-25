extends WrappableArea

@export var laser_speed := 5.0
var movement_vector:= Vector2(1,0)
var displacement_vector: Vector2


func _physics_process(delta):
	displacement_vector=movement_vector*laser_speed*delta
	displacement_vector=displacement_vector.rotated(global_rotation.z)
	global_position+=Vector3(displacement_vector.x,displacement_vector.y,0)


func _on_timer_timeout():
	queue_free()
