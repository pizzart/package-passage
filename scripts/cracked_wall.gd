extends StaticBody3D

func _on_area_body_entered(body):
	if body.is_in_group("player"):
		if body.velocity.length() > 2:
			body.emit_signal("wall_destroyed")
			$MeshInstance3D.hide()
			$Area3D.set_deferred("monitoring", false)
			$CollisionShape3D.set_deferred("disabled", true)
			$DestroyParticles.restart()
			await get_tree().create_timer(2).timeout
			queue_free()
