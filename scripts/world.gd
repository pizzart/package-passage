extends Node3D

#signal delivery_started
var game_started: bool
var delivering: bool
var delivery_id: int
var time: float = 90

func _ready():
	var id = 0
	for building in get_tree().get_nodes_in_group("building"):
		building.id = id
		id += 1
	$Car.connect("delivery_started", _on_delivery_started)
	$Car.connect("delivery_done", _on_delivery_done)
	
	HUD.show()
	$Overlay.transition()
	$Car.delivery_started.connect($Overlay._on_delivery_started)
	var tween = create_tween()
	tween.tween_property($Music, "volume_db", 0, 3.0)

func _process(delta):
#	if delivering:
	if not game_started: return
	
	time -= delta
	HUD.get_node("C/M/Time").text = "%s" % floor(time)
	
#	HUD.get_node("C/M/Time").text = ""
	
	if time <= 0:
		GameOver.get_node("C/P/V/Score").text = "score: %s" % $Car/Skills.score
		GameOver.game_over()
		
		var cfg = ConfigFile.new()
		var err = cfg.load("user://settings.cfg")
		if err == OK:
			if cfg.get_value("game", "score", 0) < $Car/Skills.score:
				GameOver.get_node("C/P/V/HighScore").show()
				GameOver.get_node("C/P/V/HighScore").text = "high score: %s" % cfg.get_value("game", "score", 0)
				cfg.set_value("game", "score", $Car/Skills.score)
		cfg.save("user://settings.cfg")
		
		get_tree().paused = true
	
#	$PauseCamera.current = false

func _input(event):
	if event.is_action_pressed("pause"):
		$PauseCamera.current = true
		$PauseCamera.position = $Car/CameraGimbal/Camera3D.global_position
		$PauseCamera.rotation = $Car/CameraGimbal/Camera3D.global_rotation
		var tween = $PauseCamera.create_tween().set_parallel()
		tween.tween_property($PauseCamera, "position", Vector3($Car.global_position.x, 30, $Car.global_position.z), 3.0).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		tween.tween_property($PauseCamera, "rotation", Vector3(-PI / 2, 0, 0), 3.0).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		PauseMenu.show()
#		await get_tree().process_frame
		get_tree().paused = true

func unpause():
#	$PauseCamera.position = $Car/CameraGimbal/Camera3D.global_position
#	$PauseCamera.rotation = $Car/CameraGimbal/Camera3D.global_rotation
#	$PauseCamera.position.y = 30
	var tween = $PauseCamera.create_tween().set_parallel()
	tween.tween_property($PauseCamera, "position", $Car/CameraGimbal/Camera3D.global_position, 1.0).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($PauseCamera, "rotation", $Car/CameraGimbal/Camera3D.global_rotation, 1.0).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	$PauseCamera.current = false

func _on_delivery_started(id: int):
	if not game_started:
		game_started = true
		HUD.get_node("C/M/Time").show()
		id = 1
		
		var tween = create_tween()
		tween.tween_property($Door, "position", $Door.position - Vector3(6, 0, 0), 1.0).set_trans(Tween.TRANS_CIRC)
		tween.tween_property($Door, "position", $Door.position - Vector3(6, 10, 0), 1.0).set_trans(Tween.TRANS_CIRC).set_delay(7)
		tween.parallel().tween_property($Wall, "position", $Wall.position - Vector3(0, 10, 0), 1.0).set_trans(Tween.TRANS_CIRC).set_delay(7)
	
	delivering = true
	delivery_id = id
	get_tree().get_nodes_in_group("building")[id].get_node("AreaMesh").show()

func _on_delivery_done():
	delivering = false
	get_tree().get_nodes_in_group("building")[delivery_id].get_node("AreaMesh").hide()
	get_tree().get_first_node_in_group("delivery_point").get_node("AreaMesh").show()
