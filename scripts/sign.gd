extends Node3D

var touched: bool

func _on_area_body_entered(body):
	if body.is_in_group("player"):
		if not touched:
			touched = true
			body.emit_signal("sign_hit")
		$HitAudio.play()
