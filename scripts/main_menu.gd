extends Node2D

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_menu_items_item_activated(index: int) -> void:
	if index==0:
		get_tree().change_scene_to_file("res://scenes/main.tscn")
