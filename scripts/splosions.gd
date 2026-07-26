extends Area3D

@onready var cshape = $CollisionShape3D
@onready var fire = $Fire

@export var startradius := 0.35
@export var maxradius := 2.0
@export var fx_overshoot := 1.05   # visual leads the hitbox, so nothing clips you outside the boom
@export var duration := 0.8        # how long the fireball lives
var radius: float
var life := 0.0


func _ready():
	radius = startradius
	cshape.shape.radius = radius
	fire.scale = Vector3.ONE * maxradius * fx_overshoot   # quad spans -1..1, so scale is the radius


func _process(delta):
	life += delta
	var p := minf(life / duration, 1.0)
	fire.material_override.set_shader_parameter("progress", p)

	if monitoring:
		# same easing curve the shader runs the crest on, so the hitbox always trails what you can see
		radius = lerpf(startradius, maxradius, 1.0 - pow(1.0 - p, 2.2))
		cshape.shape.radius = radius
		if p >= 0.8:
			monitoring = false   # shockwave's passed - stop catching latecomers, let the fire finish

	if life >= duration:
		queue_free()


func _on_body_entered(body):
	if (body is enemyclass) or (body is player):
		body.damage(4)
