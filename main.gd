extends Node2D

signal windfish_awakened

@onready var canmake = $can
@onready var wantmake = $want
@onready var impossiblegoal = $market
#
#func _ready() -> void:
	#canmake.radius = 0
	#wantmake.radius = 0
	#impossiblegoal.radius = 0

var goalfreepingcount : int = 0

var camvel : Vector2

var timescale : float = -0.25

var goalfree : bool = false

@onready var venns = [canmake, wantmake, impossiblegoal]

func _ready() -> void:
	modulate.a = 0.0
	$Camera2D.position = lerp(canmake.position * 0.5 + wantmake.position * 0.5, impossiblegoal.position, 0.50)

	var Cat = JavaScriptBridge.get_interface('Cat')
	if Cat:
		print("Cat found!")
		#Cat.set_game_size(
			#ProjectSettings.get_setting("display/window/size/viewport_width"),
			#ProjectSettings.get_setting("display/window/size/viewport_height")
		#)
		windfish_awakened.connect(
			func(): Cat.on_windfish_awakened()
		)
	else:
		print("Cat not found - You do not have access to JS")

	
func _physics_process(delta: float) -> void:
	if modulate.a < 1: modulate.a += 0.002
	if timescale < 1: timescale += 0.002
	else: timescale = 1
	var camgoal : Vector2 = canmake.position * 0.5 + wantmake.position * 0.5
	var cam_dist_to_impossible = camgoal.distance_to(impossiblegoal.position)
	if cam_dist_to_impossible < 1300 and not goalfree:
		camgoal = lerp(camgoal, impossiblegoal.position,
			clamp(
				remap(cam_dist_to_impossible, 100, 1000, 0.50, 0.00),
				0.00, 0.50
			)
		)
		canmake.radius = lerp(canmake.radius, 278.0, 0.01)
		if wantmake.radius > 278.0:
			wantmake.radius = lerp(wantmake.radius, 278.0, 0.01)
		if impossiblegoal.modulate.a < 1: impossiblegoal.modulate.a += 0.01
	else:
		canmake.radius += 1
		wantmake.radius += 1
		if canmake.radius > 300:
			if not goalfree: venns.erase(impossiblegoal); goalfree = true;
		if impossiblegoal.modulate.a > 0:
			impossiblegoal.modulate.a -= 0.01
	camvel *= 0.90
	camvel = lerp(camvel, camgoal - $Camera2D.position, 0.01)
	$Camera2D.position += camvel
	
	if randf() < 0.001 and impossiblegoal.score2 > 0:
		impossiblegoal.score2 -= 1
	
	if randf() < 0.001 and timescale >= 0.9:
		impossiblegoal.position = Vector2(randf_range(-500,500), randf_range(-500,500))
		impossiblegoal.vel = Vector2.RIGHT.rotated(randf()*TAU)*randf_range(0.1,0.2)
		impossiblegoal.radius = 278
		impossiblegoal.modulate.a = 0.0
		#impossiblegoal.score = int(impossiblegoal.score * randf_range(0.0,2.0))
	else:
		impossiblegoal.radius *= 0.9999
		if impossiblegoal.modulate.a < 1:
			impossiblegoal.modulate.a += 0.05
	
	for venset in venns:
		if timescale > 0:
			venset.position += venset.vel * timescale
	
	var check_flash : bool = true
	for venset in venns:
		if venset.flash > 0.0: check_flash = false; break;
	
	if check_flash:
		var yes_can_make : bool = false
		var yes_want_make : bool = false
		for venset in venns:
			var tomouse : Vector2 = get_global_mouse_position() - venset.position
			if tomouse.length_squared() < venset.radius*venset.radius:
				if yes_can_make or venset == canmake:
					yes_can_make = true
					venset.flash = 1.0
					if goalfree and venset == wantmake:
						goalfreepingcount += 1
						if goalfreepingcount == 10:
							windfish_awakened.emit()
							print("game over")
							#$can/Score.show()
							$want/Score.show()
					if venset == impossiblegoal:
						if yes_want_make: impossiblegoal.score2 += 1
				if venset == wantmake:
					yes_want_make = true
	
	var can_to_mouse = get_global_mouse_position() - canmake.position
	canmake.vel = lerp(canmake.vel * 0.90, can_to_mouse.limit_length(100.0) * 0.1, 0.01)

	var can_to_want : Vector2 = wantmake.position - canmake.position
	var c2w_dist_sqr = can_to_want.length_squared()
	if c2w_dist_sqr > 0:
		wantmake.vel += can_to_want / c2w_dist_sqr * 150.0 - can_to_want * 0.0003
	wantmake.vel *= 0.90

	if not goalfree:
		var want_to_goal : Vector2 = impossiblegoal.position - wantmake.position
		wantmake.vel += want_to_goal * 0.0001
