extends Node3D

var delivering: bool
var delivery_id: int
var time: float = 60

func _ready():
	var id = 0
	for building in get_tree().get_nodes_in_group("building"):
		building.id = id
		id += 1
	$Car.connect("delivery_started", _on_delivery_started)
	$Car.connect("delivery_done", _on_delivery_done)

func _process(delta):
	if delivering:
		time -= delta
		HUD.get_node("C/M/Time").text = "%ss" % floor(time)
	else:
		time = 60
		HUD.get_node("C/M/Time").text = ""
	if time <= 0:
		GameOver.show()
		GameOver.get_node("C/P/V/Score").text = "SCORE: %s" % $Car/Skills.score
		get_tree().paused = true

func _on_delivery_started(id: int):
	delivering = true
	delivery_id = id

func _on_delivery_done():
	delivering = false
