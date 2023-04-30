extends Node

var score: int = 0
var air_time: float
var drift_time: float
var active_skills = {}
@onready var car: CharacterBody3D = get_parent()

func _ready():
	car.connect("ring_entered", _on_ring_entered)
	car.connect("wall_destroyed", _on_wall_destroyed)
	car.connect("delivery_done", _on_delivery_done)

func _process(delta):
	HUD.get_node("C/M/Score").text = "SCORE: %s" % score
	
	long_skill("air", "AIR TIME: %ss", air_time, not car.is_on_floor(), delta, 100)
	long_skill("drift", "DRIFT TIME: %ss", drift_time, car.drifting and car.velocity.length() > 2, delta, 150)
	
	HUD.get_node("C/M/Skills").text = ""
	for skill in active_skills.values():
		HUD.get_node("C/M/Skills").text += skill + "\n"

func _on_ring_entered():
	score += 200
	active_skills["ring"] = "RING"
	await get_tree().create_timer(3).timeout
	active_skills.erase("ring")

func _on_wall_destroyed():
	score += 150
	active_skills["wall"] = "DESTRUCTION"
	await get_tree().create_timer(3).timeout
	active_skills.erase("wall")

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

func _on_delivery_done():
#	if car.get_parent().delivering:
	score += 1000
	active_skills["delivery"] = "PACKAGE DELIVERED"
	await get_tree().create_timer(3).timeout
	active_skills.erase("delivery")
