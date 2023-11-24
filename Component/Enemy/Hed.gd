extends CharacterBody2D

@onready var player : CharacterBody2D
@onready var animated_sprite = $AnimatedSprite2D
@onready var state_chart = $StateChart
@onready var patrol_timer = $PatrolTimer

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
		state_chart.send_event("player_entered")


func _on_area_2d_body_exited(body):
	if (body.is_in_group("Player")):
		player = null
		state_chart.send_event("player_exited")


func _on_patrol_timer_timeout():
	state_chart.send_event("start_patrol")


func _on_idle_state_entered():
	patrol_timer.start(3)


func _on_chasing_state_entered():
	if !player:
		state_chart.send_event("start_patrol")
	

func _on_patroling_state_entered():
	await get_tree().create_timer(3).timeout
	state_chart.send_event("stop_patrol")


func _on_chasing_state_physics_processing(delta):
	pass
	#while(player):	
	#	lerp(global_position, player.global_position, 5)
