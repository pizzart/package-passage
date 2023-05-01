extends Node

@onready var init_cam_rot = $Map/Camera3D.rotation

func _enter_tree():
	load_settings()

func _ready():
	$Overlay/M.hide()
	var tween = create_tween().set_parallel()
	tween.tween_property($Overlay/Panel, "modulate", Color.TRANSPARENT, 3.0)
	tween.tween_property($MenuMusic, "volume_db", 0, 3.0)

func load_settings():
	var cfg = ConfigFile.new()
	var err = cfg.load("user://settings.cfg")
	if err != OK:
		if ERR_FILE_NOT_FOUND:
			cfg.set_value("audio", "mus", 1.0)
			cfg.set_value("audio", "sfx", 1.0)
			cfg.set_value("game", "score", 0)
			cfg.save("user://settings.cfg")
		return
	
	var mus = cfg.get_value("audio", "mus", 1.0)
	var sfx = cfg.get_value("audio", "sfx", 1.0)
	
	AudioServer.set_bus_volume_db(2, linear_to_db(mus))
	AudioServer.set_bus_volume_db(1, linear_to_db(sfx))
	
	$Overlay/C/C/V/Music/MusicSlider.value = mus
	$Overlay/C/C/V/Sound/SoundSlider.value = sfx

func save_settings():
	var cfg = ConfigFile.new()
	cfg.set_value("audio", "mus", $Overlay/C/C/V/Music/MusicSlider.value)
	cfg.set_value("audio", "sfx", $Overlay/C/C/V/Sound/SoundSlider.value)
	cfg.save("user://settings.cfg")

func _on_play_area_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == 1:
			get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_play_area_mouse_entered():
	$Map/Play.modulate = Color("#f20081")
	$Map/Play.shaded = false
	$Map/Play/HoverAudio.play()

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
	$Map/Stop/HoverAudio.play()

func _on_stop_area_mouse_exited():
	$Map/Stop.modulate = Color.WHITE
	$Map/Stop.shaded = true

func _on_music_slider_value_changed(value):
	AudioServer.set_bus_volume_db(2, linear_to_db(value))

func _on_sound_slider_value_changed(value):
	AudioServer.set_bus_volume_db(1, linear_to_db(value))

func _on_settings_area_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == 1:
			var tween = create_tween().set_parallel()
			tween.tween_property($Map/Camera3D, "rotation", init_cam_rot + Vector3(PI / 2, 0, 0), 1.0).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
			tween.tween_property($Overlay/C, "modulate", Color.WHITE, 1.0)
#			$Map/Camera3D.rotation.x = deg_to_rad(100)
			$Overlay/C.show()

func _on_settings_area_mouse_entered():
	$Map/Settings.modulate = Color("#f20081")
	$Map/Settings.shaded = false
	$Map/Settings/HoverAudio.play()

func _on_settings_area_mouse_exited():
	$Map/Settings.modulate = Color.WHITE
	$Map/Settings.shaded = true

func _on_sound_slider_drag_ended(value_changed):
	$ClickSound.play()

func _on_back_pressed():
	save_settings()
	
	$ClickSound.play()
	
	var tween = create_tween().set_parallel()
	tween.tween_property($Map/Camera3D, "rotation", init_cam_rot, 1.0).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	tween.tween_property($Overlay/C, "modulate", Color.TRANSPARENT, 1.0)
	await tween.finished
	$Overlay/C.hide()
