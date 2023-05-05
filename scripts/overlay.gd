extends CanvasLayer

const TUTORIAL = {
	"quick": "quick to understand, i see. get the package to the house before the timer runs out.",
	"welcome": "welcome to your new job. here you take packages and deliver them to people.",
	"wasd": "using WASD, try to pick one up from the point.",
	"timer": "a timer is now running. deliver the package before it runs out!",
	"arrow": "the arrow shows the direction to the recipient's house.",
	"points": "on your way you will find signs, cones, ramps, rings, etc. they give points. get as many of them as you can!",
	"drift": "you can drift using SPACE. it also gives points, but reduces grip. use wisely.",
	"tab": "switch between camera angles using TAB. press ESCAPE to pause the game.",
	"return": "after delivering the package, return back to the point for another package, since the timer doesn't stop because you are on your job and have to work the entire work day otherwise your boss will get mad and you will be fired and you will have to find another job because we live ",
	"hf": "have fun!",
}
const ORDER = ["welcome", "wasd", "timer", "arrow", "points", "drift", "tab", "return", "hf"]
var line: int = -1

func _ready():
#	get_parent().get_node("Car").connect("delivery_started", _on_delivery_started)
	next_line()

func transition():
	var tween = create_tween()
	tween.tween_property($Panel, "modulate", Color.TRANSPARENT, 3.0)

func next_line():
	line += 1
	if line >= ORDER.size():
		$M/Explanation.text = ""
		return
	
	if ORDER[line] == "wasd":
		$Timer.stop()
	
	$M/Explanation.text = TUTORIAL[ORDER[line]]
	$M/Explanation.visible_ratio = 0
	var tween = create_tween()
	if ORDER[line] == "return":
		tween.tween_property($M/Explanation, "visible_ratio", 1.0, 7.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	else:
		tween.tween_property($M/Explanation, "visible_ratio", 1.0, 1.5)

func other_line(key: String):
	$M/Explanation.text = TUTORIAL[key]
	$M/Explanation.visible_ratio = 0
	var tween = create_tween()
	tween.tween_property($M/Explanation, "visible_ratio", 1.0, 1.5)

func _on_timer_timeout():
	next_line()

func _on_delivery_started(id: int):
	if line < ORDER.find("wasd"):
		$Timer.stop()
		other_line("quick")
		line = ORDER.find("timer") - 1
	elif line == ORDER.find("wasd"):
		next_line()
	else:
		return
	$Timer.start()
