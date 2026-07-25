extends WrappableArea

@export var laser_speed := 5.0
var movement_vector:= Vector2(1,0)
var displacement_vector: Vector2

func _ready() -> void:
	displacement_vector=movement_vector*laser_speed
	displacement_vector=displacement_vector.rotated(global_rotation.z)
	
func _physics_process(delta):
	global_position+=Vector3(displacement_vector.x*delta,displacement_vector.y*delta,0)


func _on_timer_timeout():
	queue_free()
