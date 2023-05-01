extends Node3D

var RNG = RandomNumberGenerator.new()

func _ready():
	RNG.randomize()

func _on_area_body_entered(body):
	if body.is_in_group("player"):
		if not body.get_parent().delivering:
			body.emit_signal("delivery_started", RNG.randi() % get_tree().get_nodes_in_group("building").size())
			$AreaMesh.hide()
			$DeliveryAudio.play()
