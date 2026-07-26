extends Node2D

@onready var howtoplay = $"How to Play"
@onready var menu = $MenuItems

func _ready() -> void:
	howtoplay.visible=false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_menu_items_item_activated(index: int) -> void:
	if index==0:
		get_tree().change_scene_to_file("res://scenes/game.tscn")
	elif index==1:
		if !howtoplay.visible:
			howtoplay.visible = true
		else:
			howtoplay.visible=false
			
func _on_menu_items_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	menu.emit_signal("item_activated", index)
