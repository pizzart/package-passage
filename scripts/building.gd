extends Node3D

var id: int = 0

func _on_area_body_entered(body):
	if body.is_in_group("player"):
		if body.get_parent().delivering and body.get_parent().delivery_id == id:
			body.emit_signal("delivery_done")
