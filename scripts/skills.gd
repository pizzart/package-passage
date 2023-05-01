extends Node

var hud_score: int = 0
var score: int = 0
var air_time: float
var drift_time: float
var active_skills = {}
@onready var car: CharacterBody3D = get_parent()

func _ready():
	car.connect("ring_entered", _on_ring_entered)
	car.connect("wall_destroyed", _on_wall_destroyed)
	car.connect("bin_hit", _on_bin_hit)
	car.connect("cone_hit", _on_cone_hit)
	car.connect("sign_hit", _on_roadsign_hit)
	car.connect("light_hit", _on_roadsign_hit)
	car.connect("pot_destroyed", _on_pot_destroyed)
	car.connect("delivery_done", _on_delivery_done)

func _process(delta):
	if hud_score < score:
		hud_score += roundi(delta * 300)
		HUD.get_node("CountAudio").play()
		HUD.get_node("CountAudio").pitch_scale += delta
	else:
		HUD.get_node("CountAudio").stop()
		HUD.get_node("CountAudio").pitch_scale = 1
	
		if hud_score > score:
			hud_score = score
	
	HUD.get_node("C/M/Score").text = "SCORE: %s" % hud_score
	
	air_time = long_skill("air", "AIR TIME: %ss", air_time, not car.is_on_floor(), delta, 100)
	drift_time = long_skill("drift", "DRIFT TIME: %ss", drift_time, car.drifting and car.velocity.length() > 2, delta, 50)
	
	HUD.get_node("C/M/Skills").text = ""
	for skill in active_skills.values():
		HUD.get_node("C/M/Skills").text += skill + "\n"

func short_skill(skill: String, hud_text: String, add_score: int):
	score += add_score
	active_skills[skill] = hud_text
	await get_tree().create_timer(3).timeout
	active_skills.erase(skill)

func long_skill(skill: String, hud_text: String, time: float, condition: bool, delta: float, mult: int):
	if condition:
		time += delta
		if time > 0.2:
			active_skills[skill] = hud_text % snappedf(time, 0.01)
	else:
		if time > 0.2:
			score += snappedi(time * mult, mult)
			active_skills.erase(skill)
		time = 0
	return time

func _on_ring_entered():
	short_skill("ring", "RING JUMP", 250)

func _on_wall_destroyed():
	short_skill("wall", "WALL DESTRUCTION", 150)

func _on_delivery_done():
	short_skill("delivery", "PACKAGE DELIVERED", 1000)

func _on_bin_hit():
	short_skill("bin", "LITTERING", 150)

func _on_cone_hit():
	short_skill("cone", "ROAD RAGE", 150)

func _on_roadsign_hit():
	short_skill("roadsign", "LAWBREAKER", 150)

func _on_pot_destroyed():
	short_skill("pot", "VANDALISM", 200)
