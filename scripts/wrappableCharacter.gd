class_name WrappableCharacter extends CharacterBody3D

@export var screen_extent:= Vector2(16.0,9.0) #hardcoded
	
func _process(_delta):
	
	global_position.z = 0.0
	
	if global_position.y<-screen_extent.y/2:
		global_position.y=screen_extent.y/2
	elif global_position.y > screen_extent.y/2:
		global_position.y = -screen_extent.y/2
	if global_position.x<-screen_extent.x/2:
		global_position.x=screen_extent.x/2
	elif global_position.x > screen_extent.x/2:
		global_position.x = -screen_extent.x/2
