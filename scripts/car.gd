extends CharacterBody3D

signal ring_entered
signal wall_destroyed
signal bin_hit
signal cone_hit
signal sign_hit
signal light_hit
signal delivery_started(id: int)
signal delivery_done

const CAM_LOW: float = -50
const CAM_LOW_Z = 13
const CAM_HIGH: float = -90
const CAM_HIGH_Z = 15

var cam_rotation = CAM_LOW
var cam_height = CAM_LOW_Z
#var slip_speed = 15.0
var traction_slow = 0.2
var traction_fast = 0.01

var drifting = false
var drift_time: float = 0.3

var gravity = -20
var wheel_base = 1.1  # distance between front/rear axles
var steering_limit = 11  # front wheel max turning angle (deg)
var accel_power = 0
var accel_rate = 0.17
var accel_init = 0.23
#var accel_rate = 10.0
var engine_power = 36.0
var braking = -25.0
var friction = -1.0
var drag = -3.0
var max_speed_reverse = 13.0

var last_velocity: Vector3
var was_on_floor: bool

var acceleration = Vector3.ZERO  # current acceleration
var steer_angle = 0.0  # current wheel angle
var traction = traction_slow

var engine_audio_time: float = 0

#var sample_hz = 22050.0 # Keep the number of samples to mix low, GDScript is not super fast.
#var pulse_hz = 220.0
#var phase = 0.0
#
#var playback: AudioStreamPlayback = null # Actual playback stream, assigned in _ready().

#func _ready():
#	$EngineAudio.stream.mix_rate = sample_hz # Setting mix rate is only possible before play().
#	$EngineAudio.play()
#	playback = $EngineAudio.get_stream_playback()
#	_fill_buffer() # Prefill, do before play() to avoid delay.

func _process(delta):
#	engine_audio_time += delta
#	if engine_audio_time >= 0.02:
#		$EngineAudio.play()
#		engine_audio_time = 0
	var h_vel = Vector2(last_velocity.x, last_velocity.z)
	$EngineAudio.pitch_scale = h_vel.length() / 4 + 0.11
	$EngineAudio2.pitch_scale = h_vel.length() / 4 + 0.11
#	pulse_hz = (velocity.length() * 20) + 20
#	_fill_buffer()
#	$EngineAudio.play()
	
	$CameraGimbal.rotation.y = lerp_angle($CameraGimbal.rotation.y, rotation.y - PI, delta)
#	$CameraGimbal.rotation.y = -PI
	$CarBack.global_position = position + Vector3(0, 0, -1.4).rotated(Vector3.UP, rotation.y)
	$CarBack.rotation.y = lerp_angle($CarBack.rotation.y, clampf(rotation.y, rotation.y - PI / 4, rotation.y + PI / 4), delta * 2)
	$CarBack.rotation.x = lerp_angle($CarBack.rotation.x, rotation.x, delta * 2)
#	$BackCollision.global_position = $CarBack/Collision.global_position
#	$BackCollision.rotation = $CarBack/Collision.rotation
	$ArrowGimbal.visible = get_parent().delivering
	if get_parent().delivering:
		$ArrowGimbal.visible = true
#		$ArrowGimbal.global_position = global_position
		$ArrowGimbal.look_at(get_tree().get_nodes_in_group("building")[get_parent().delivery_id].global_position)
#		$ArrowGimbal.global_rotation.y = (Vector3.RIGHT.angle_to(global_position.direction_to(get_tree().get_nodes_in_group("building")[get_parent().delivery_id].global_position)) + PI / 2)

func _physics_process(delta):
	$CameraGimbal.position = $CameraGimbal.position.lerp(position + Vector3(0, 1, 0), delta * 20)
#	steering = lerp(steering, Input.get_axis("right", "left"), delta * 5)
#	steering = Input.get_axis("right", "left")
#	engine_force = Input.get_action_strength("accelerate") * 300
#	brake = Input.get_action_strength("brake") * 20

#func _physics_process(delta):
	if is_on_floor():
		get_input(delta)
		apply_friction(delta)
		calculate_steering(delta)
		
		rotation.x = lerpf(rotation.x, -get_floor_angle(), delta * 10)
		rotation.z = 0
		
		if not was_on_floor:
			$FallAudio.volume_db = linear_to_db(abs(last_velocity.y) / 70)
			$FallAudio.play()
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
		rotation.x = lerpf(rotation.x, clampf(-velocity.y / 10, -PI / 4, PI), delta * 5)
		acceleration.y += last_velocity.y
		acceleration.x = 0
		acceleration.z = 0
		accel_power = 0
	
	was_on_floor = is_on_floor()
	
	$RL/SmokeParticles.emitting = drifting and is_on_floor()
	$RR/SmokeParticles.emitting = drifting and is_on_floor()
	if drifting and is_on_floor():
		if not $DriftAudio.playing:
			$DriftAudio.play()
	else:
			$DriftAudio.stop()
	
	last_velocity = get_real_velocity()
	
	acceleration.y = gravity
#	acceleration.x *= accel_rate
#	acceleration.z *= accel_rate
	velocity += acceleration * delta
	move_and_slide()

#func _fill_buffer():
#	var increment = pulse_hz / sample_hz
#
#	var to_fill = playback.get_frames_available()
#	while to_fill > 0:
##		print(phase)
#		playback.push_frame(Vector2.ONE * (ceil(phase) - phase)) # Audio frames are stereo.
#		phase = fmod(phase + increment, 1.0)
#		to_fill -= 1

func _input(event):
	if event.is_action_pressed("switch_camera"):
		if cam_rotation == CAM_LOW:
			cam_rotation = CAM_HIGH
			cam_height = CAM_HIGH_Z
		else:
			cam_rotation = CAM_LOW
			cam_height = CAM_LOW_Z
		
		var tween = create_tween().set_parallel()
		tween.tween_property($CameraGimbal, "rotation", Vector3(deg_to_rad(cam_rotation), $CameraGimbal.rotation.y, 0), 0.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		tween.tween_property($CameraGimbal/Camera3D, "position", Vector3(0, 0, cam_height), 0.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

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
	
	drifting = Input.is_action_pressed("handbrake") and velocity.length() > 2 and d < 0 and abs(steer_angle) > 0
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

func get_input(delta: float):
	var turn = Input.get_axis("left", "right")
	steer_angle = turn * deg_to_rad(steering_limit) * clampf((engine_power - velocity.length()) / engine_power, 0.5, 1)
	if drifting:
		steer_angle *= 1.5
	$FR.rotation.y = steer_angle * 2
	$FL.rotation.y = steer_angle * 2
#	acceleration = Vector3.ZERO
	if Input.is_action_pressed("accelerate"):
		accel_power = clamp(accel_power + delta * Input.get_action_strength("accelerate") * accel_rate, accel_init, 1)
#		accel_power *= (velocity.length() / engine_power * 2) + 0.5
#		print(velocity.length() / engine_power + 0.1)
		acceleration = transform.basis.z * engine_power * accel_power
	if Input.is_action_pressed("brake"):
		accel_power = clamp(accel_power - delta * Input.get_action_strength("brake") * accel_rate, -1, -accel_init)
		acceleration = transform.basis.z * braking * -accel_power
	if Input.get_axis("accelerate", "brake") == 0:
		accel_power = 0
		acceleration.x = 0
		acceleration.z = 0
	
#	drifting = Input.is_action_pressed("handbrake")
#	acceleration = acceleration.clamp(-Vector3(braking, 1000, braking), Vector3(engine_power, 1000, engine_power))
