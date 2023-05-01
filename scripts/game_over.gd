extends CanvasLayer

func _on_restart_pressed():
	get_tree().reload_current_scene()
	get_tree().paused = false
	HUD.show()
	$C/P/V/HighScore.hide()
	hide()

func game_over():
	await get_tree().create_timer(1.0).timeout
	HUD.hide()
	show()
	$Audio.play()

func _on_restart_mouse_entered():
	$HoverAudio.play()
