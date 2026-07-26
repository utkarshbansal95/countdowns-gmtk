extends WrappableArea

@export var laser_speed := 8.0
@export var color := Color(0.3, 0.6, 1.0)
@export var dmg := 1

var direction := Vector3.RIGHT
var shooter: Node


func _ready():
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = color
	$Blue2/Blue.material_override = mat

func _physics_process(delta):
	global_position += direction * laser_speed * delta


func _on_timer_timeout():
	queue_free()

func _on_body_entered(body):
	if body == shooter:   # muzzle sits inside the enemy's own collider
		return
	if "health" in body:
		body.damage(dmg) #damage
	queue_free()
