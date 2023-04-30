extends Node

#func _on_quit_pressed():
#	get_tree().quit()

func _on_play_area_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == 1:
			get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_play_area_mouse_entered():
	$Map/Play.modulate = Color("#f20081")
	$Map/Play.shaded = false

func _on_play_area_mouse_exited():
	$Map/Play.modulate = Color.WHITE
	$Map/Play.shaded = true

func _on_stop_area_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == 1:
			get_tree().quit()

func _on_stop_area_mouse_entered():
	$Map/Stop.modulate = Color("#f20081")
	$Map/Stop.shaded = false

func _on_stop_area_mouse_exited():
	$Map/Stop.modulate = Color.WHITE
	$Map/Stop.shaded = true
