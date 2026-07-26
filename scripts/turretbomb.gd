class_name tbomb extends WrappableCharacter

@export var shine_color := Color(0.2, 1.0, 1.0)
@export var shine_min := 1.0
@export var shine_max := 4.0
@export var shine_speed := 5.0

var _shine_mats: Array[StandardMaterial3D] = []
var _pulse := 0.0

func _ready() -> void:
	for m in _mesh_children(self):
		var mat := StandardMaterial3D.new()
		mat.albedo_color = shine_color
		mat.emission_enabled = true
		mat.emission = shine_color
		m.material_override = mat
		_shine_mats.append(mat)

func _process(delta):
	super._process(delta)   # keeps WrappableCharacter's screen wrap alive
	_pulse += delta * shine_speed
	var energy: float = lerp(shine_min, shine_max, 0.5 + 0.5 * sin(_pulse))
	for mat in _shine_mats:
		mat.emission_energy_multiplier = energy

# the .obj instances as a subtree, so the MeshInstance3D isn't always a direct child
func _mesh_children(node: Node) -> Array[MeshInstance3D]:
	var found: Array[MeshInstance3D] = []
	for child in node.get_children():
		if child is MeshInstance3D:
			found.append(child)
		found.append_array(_mesh_children(child))
	return found

func _physics_process(_delta):
	velocity=velocity.lerp(Vector3(0,0,0), 0.01)
	move_and_slide()
