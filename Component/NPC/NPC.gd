extends CharacterBody2D

@onready var player : CharacterBody2D
@onready var animated_sprite = $AnimatedSprite2D

enum FACING{RIGHT,LEFT}
var face_direction
var player_position : Vector2


func _process(delta):
	#global_position = get_global_mouse_position()
	if !player:		
		return
		
	player_position = (player.global_position - global_position).normalized()
	
	# Handle Player sprite orientation
	if player_position.x > 0:
		face_direction = FACING.RIGHT
		animated_sprite.flip_h = true
	#elif mouse_direction.x < 0 and not animated_sprite.flip_h:
	elif player_position.x < 0:
		face_direction = FACING.LEFT
		animated_sprite.flip_h = false

func _on_area_2d_area_entered(area):
	pass


func _on_area_2d_body_entered(body):
	if (body.is_in_group("Player")):
		player = body


func _on_area_2d_body_exited(body):
	if (body.is_in_group("Player")):
		player = null
