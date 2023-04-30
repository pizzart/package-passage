extends CanvasLayer

func _on_restart_pressed():
	get_tree().reload_current_scene()
	get_tree().paused = false
	hide()
