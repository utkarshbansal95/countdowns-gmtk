extends Area3D

@export var laser_speed := 8.0
@export var color := Color(0.3, 0.6, 1.0)
@export var dmg := 1

var direction := Vector3.RIGHT
var shooter: Node

# One material per colour, shared by every laser. A fresh StandardMaterial3D per shot was
# ~13 allocs/sec at the RenderingServer, and meant no two lasers could ever batch.
static var _mats: Dictionary = {}

static func _mat_for(c: Color) -> StandardMaterial3D:
	var m: StandardMaterial3D = _mats.get(c)
	if m == null:
		m = StandardMaterial3D.new()
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		m.albedo_color = c
		_mats[c] = m
	return m


func _ready():
	$Blue2/Blue.material_override = _mat_for(color)

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
