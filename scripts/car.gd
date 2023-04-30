extends CharacterBody3D

signal ring_entered
signal wall_destroyed
signal bin_hit
signal cone_hit
signal delivery_started(id: int)
signal delivery_done
#var slip_speed = 15.0
var traction_slow = 0.2
var traction_fast = 0.01

var drifting = false
var drift_time: float = 0.5

var gravity = -20
var wheel_base = 1.1  # distance between front/rear axles
var steering_limit = 7  # front wheel max turning angle (deg)
#var accel_power = 0.1
var engine_power = 15.0
var braking = -10.0
var friction = -1.0
var drag = -3.0
var max_speed_reverse = 12.0

var last_velocity: Vector3

var acceleration = Vector3.ZERO  # current acceleration
var steer_angle = 0.0  # current wheel angle
var traction = traction_slow

func _process(delta):
	$CameraGimbal.position = $CameraGimbal.position.lerp(position + Vector3(0, 1, 0), delta * 20)
	$CameraGimbal.rotation.y = lerp_angle($CameraGimbal.rotation.y, rotation.y - PI, delta)
#	$CameraGimbal.rotation.y = -PI
	$CarBack.global_position = position + Vector3(0, 0, -1.4).rotated(Vector3.UP, rotation.y)
	$CarBack.rotation.y = lerp_angle($CarBack.rotation.y, clampf(rotation.y, rotation.y - PI / 4, rotation.y + PI / 4), delta * 2)
#	$BackCollision.global_position = $CarBack/Collision.global_position
#	$BackCollision.rotation = $CarBack/Collision.rotation
	$ArrowGimbal.visible = get_parent().delivering
	if get_parent().delivering:
		$ArrowGimbal.visible = true
#		$ArrowGimbal.global_position = global_position
		$ArrowGimbal.look_at(get_tree().get_nodes_in_group("building")[get_parent().delivery_id].global_position)
#		$ArrowGimbal.global_rotation.y = (Vector3.RIGHT.angle_to(global_position.direction_to(get_tree().get_nodes_in_group("building")[get_parent().delivery_id].global_position)) + PI / 2)

#func _physics_process(delta):
#	steering = lerp(steering, Input.get_axis("right", "left"), delta * 5)
#	steering = Input.get_axis("right", "left")
#	engine_force = Input.get_action_strength("accelerate") * 300
#	brake = Input.get_action_strength("brake") * 20

#func _physics_process(delta):
	if is_on_floor():
		get_input()
		apply_friction(delta)
		calculate_steering(delta)
		
		rotation.x = lerpf(rotation.x, -get_floor_angle(), delta * 10)
		rotation.z = 0
#		$FloorCast.force_shapecast_update()
#		if $FloorCast.is_colliding():
#			var normals = []
#			for n in $FloorCast.get_collision_count():
#				normals.append($FloorCast.get_collision_normal(n))
#			normals.sort()
#			rotation.x = lerpf(rotation.x, -Vector3.UP.angle_to(normals[0]), delta * 10)
#			rotation.z = 0
#			rotation.z = lerpf(rotation.z, Vector3.UP.angle_to(normals[0]), delta * 10)
#		else:
#			rotation.x = lerpf(rotation.x, 0, delta * 10)
	else:
		rotation.x = lerpf(rotation.x, clampf(-velocity.y / 10, -PI / 4, PI / 4), delta * 5)
		acceleration.y += last_velocity.y
	
	$RL/SmokeParticles.emitting = drifting and is_on_floor()
	$RR/SmokeParticles.emitting = drifting and is_on_floor()
	
	acceleration.y = gravity
	velocity += acceleration * delta * 1.2
	last_velocity = get_real_velocity()
	move_and_slide()
	
#	for idx in get_slide_collision_count():
#		var collision = get_slide_collision(idx)
#		if collision.get_collider() is RigidBody3D:
#			collision.get_collider().apply_central_impulse(-collision.get_normal() * last_velocity.length())

func apply_friction(delta):
	if velocity.length() < 0.2 and acceleration.length() == 0:
		velocity.x = 0
		velocity.z = 0
	var friction_force = velocity * friction * delta
	var drag_force = velocity * velocity.length() * drag * delta
	acceleration += drag_force + friction_force

func calculate_steering(delta):
	var rear_wheel = transform.origin + transform.basis.z * wheel_base / 2.0
	var front_wheel = transform.origin - transform.basis.z * wheel_base / 2.0
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(transform.basis.y, steer_angle) * delta
	var new_heading = rear_wheel.direction_to(front_wheel)
	
	var d = new_heading.dot(velocity.normalized())
	
	drifting = drifting and velocity.length() > 2 and d < 0 and abs(steer_angle) > 0.1
	if drifting:
		drift_time = 0.5
	else:
		if drift_time > 0:
			drifting = true
		drift_time -= delta
	# traction
#	if not drifting and velocity.length() > slip_speed:
#		drifting = true
#	if drifting and velocity.length() < slip_speed and steer_angle == 0:
#		drifting = false
	traction = lerpf(traction, traction_fast if drifting else traction_slow, delta * 2)
#	print(traction)

	if d > 0:
		velocity = new_heading * min(velocity.length(), max_speed_reverse)
	if d < 0:
#		velocity = -new_heading * velocity.length()
		velocity = lerp(velocity, -new_heading * (velocity.length() - abs(steer_angle) * 1.5), traction)
	look_at(transform.origin + new_heading, transform.basis.y)

func get_input():
	var turn = Input.get_axis("left", "right")
	steer_angle = turn * deg_to_rad(steering_limit)
	if drifting:
		steer_angle *= 1.5
	$FR.rotation.y = steer_angle * 2
	$FL.rotation.y = steer_angle * 2
	acceleration = Vector3.ZERO
	if Input.is_action_pressed("accelerate"):
		acceleration = transform.basis.z * engine_power * Input.get_action_strength("accelerate")
	if Input.is_action_pressed("brake"):
		acceleration = transform.basis.z * braking * Input.get_action_strength("brake")
	drifting = Input.is_action_pressed("handbrake")
#	acceleration = acceleration.clamp(-Vector3(braking, 1000, braking), Vector3(engine_power, 1000, engine_power))
