extends Area3D

@onready var cshape = $CollisionShape3D

@export var startradius = 1
@export var rate_of_expansion = 1
@export var maxradius = 2
var radius: float

func _ready():
	radius = startradius
	cshape.radius = radius

func _process(_delta):
	if radius < maxradius:
		radius += rate_of_expansion
	cshape.radius = radius


func _on_body_entered(body):
	if (body is enemyclass) or (body is player):
		body.damage(4)
