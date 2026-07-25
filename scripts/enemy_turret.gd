class_name Eenemy_Turret extends Turret

var target_group := "player"

func _get_aim_target() -> Vector3:
	return global_position + Vector3.RIGHT
