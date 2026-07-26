extends WrappableArea

@export var laser_speed := 8.0
var direction := Vector3.RIGHT   # set by main after the laser is placed in the world

func _physics_process(delta):
	global_position += direction * laser_speed * delta


func _on_timer_timeout():
	queue_free()
