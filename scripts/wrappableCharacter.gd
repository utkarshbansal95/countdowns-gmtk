class_name WrappableCharacter extends CharacterBody2D

var screen_size: Vector2

func _ready():
	screen_size = get_viewport_rect().size
	
func _process(delta):
	if global_position.y<0:
		global_position.y=screen_size.y
	elif global_position.y>screen_size.y:
		global_position.y=0
	if global_position.x<0:
		global_position.x=screen_size.x
	elif global_position.x>screen_size.x:
		global_position.x=0
