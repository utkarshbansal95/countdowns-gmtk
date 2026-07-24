class_name Wrappable extends CharacterBody2D

var screen_size: Vector2
var wrap_margin: float = 50.0

func _ready():
	screen_size = get_viewport_rect().size
	for child in get_children():
		if child is Sprite2D:
			var size = child.texture.get_size() * child.scale
			wrap_margin = max(size.x, size.y) / 2.0
			break

func _physics_process(delta):
	if global_position.y+wrap_margin<0:
		global_position.y=screen_size.y-wrap_margin
	if global_position.y+wrap_margin>screen_size.y:
		global_position.y=-wrap_margin
	if global_position.x+wrap_margin<0:
		global_position.x=screen_size.x-wrap_margin
	if global_position.x+wrap_margin>screen_size.x:
		global_position.x=-wrap_margin
