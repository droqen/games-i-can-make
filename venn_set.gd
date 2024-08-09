@tool
extends Node2D
class_name VennSet

var vel : Vector2
var flash : float = 0.0
var score : int = 0
var score2 : int = 0

@export var radius : float = 10.0
@export var colour : Color = Color.RED
@export var alpha : float = 1.0

func _ready() -> void:
	material = load("res://venn_material.tres")

func _physics_process(_delta: float) -> void:
	queue_redraw()
	if not Engine.is_editor_hint():
		if flash == 1.0: score += 1
		if flash > 0.0: flash -= 0.02
		if flash < 0.0: flash = 0.0
		if score > 0:
			if name == 'want':
				$Score.text = '%d you love' % score
			elif name == 'can':
				$Score.text = 'made %d games in total' % score
			elif score2 > 0:
				$Score.text = '%d released,\n %d you like'%[score,score2]
			else:
				$Score.text = '%d released\n'%[score]
		else:
			$Score.text = ''

func _draw() -> void:
	var c : Color = colour; c.a = alpha;
	
	draw_circle(Vector2.ZERO, radius, c, true, -1, true)
	
	if flash > 0.0:
		c.a *= flash
		draw_circle(Vector2.ZERO, radius + 25, c, false, 10, true)
