extends Area2D

class_name Bullet

@export var bullet_speed : float = 5
@export var bullet_damage : int = 1
@export var faction_id : FactionId.Id

var _direction : Vector2 = Vector2.RIGHT

func _physics_process(delta):
	position += _direction * bullet_speed * delta

func launch(initial_pos : Vector2, dir : Vector2, speed) :
	position = initial_pos
	_direction = dir
	bullet_speed = speed
	# rotaition = dir angle angle plus a quart er of pi
	rotation += dir.angle() + PI/4

func _on_visible_on_screen_notifier_2d_screen_exited():
	self.queue_free()


func _on_area_entered(area):
	if area.is_in_group("health") :
		area.get_damaged(bullet_damage , faction_id, global_position)
		self.queue_free()

func _on_body_entered(body):
	pass # Replace with function body.
