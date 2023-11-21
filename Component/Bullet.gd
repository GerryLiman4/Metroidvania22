extends Node2D

class_name Bullet

@export var bullet_speed : float = 5
var _direction : Vector2 = Vector2.RIGHT

func _physics_process(delta):
	position += _direction * delta
	
	print(position)

func launch(direction : Vector2) :
	_direction = direction * bullet_speed

func _on_visible_on_screen_notifier_2d_screen_exited():
	self.queue_free()
