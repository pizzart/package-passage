extends CanvasLayer

func _on_continue_pressed():
	get_tree().get_first_node_in_group("world").unpause()
	$PressAudio.play()
	get_tree().paused = false
	hide()

func _on_quit_pressed():
	$PressAudio.play()
	HUD.hide()
	hide()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_button_mouse_entered():
	$HoverAudio.play()
