extends Node3D

func _on_area_body_entered(body):
	if body.is_in_group("player"):
		body.emit_signal("pot_destroyed")
		$Pot.hide()
#		$Pot.freeze = true
		$Area3D.set_deferred("monitoring", false)
		$Pot/StaticBody3D/CollisionShape3D.set_deferred("disabled", true)
		$DestroyParticles.restart()
		$HitAudio.play()
		await get_tree().create_timer(2).timeout
		queue_free()
