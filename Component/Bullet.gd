extends Node2D

class_name Bullet

@export var bullet_speed : float = 5
var _direction : Vector2 = Vector2.RIGHT

func _physics_process(delta):
	position += _direction * bullet_speed * delta
	
	print(position)

func launch(initial_pos : Vector2, dir : Vector2, speed) :
	position = initial_pos
	_direction = dir
	bullet_speed = speed
	# rotaition = dir angle angle plus a quart er of pi
	rotation += dir.angle() + PI/4

func _on_visible_on_screen_notifier_2d_screen_exited():
	self.queue_free()
