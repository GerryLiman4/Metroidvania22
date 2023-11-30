extends CharacterBody2D

class_name BaseEnemy

@export var animated_sprite : AnimatedSprite2D 
@export var health : Health

@export var enemy_state : StateChart

@export var GRAVITY : float = 600.0
@export var WALK_SPEED : float = 120.0
@export var CHASE_SPEED : float = 200.0
@export var MAX_FALL : float = 400.0
@export var JUMP_VELOCITY : float = -350.0

enum FACING{RIGHT,LEFT}
@export var face_direction : FACING
@export var contact_damage : int = 1

const STATE_EVENT = {
	"PLAYER_ENTERED" : "player_entered",
	"START_PATROL" : "start_patrol",
	"PLAYER_EXITED" : "player_exited",
	"STOP_PATROL" : "stop_patrol"
}

const STATE_CONTROL = {
	"NONE" : "NONE",
	"IDLE" : "IDLE",
	"CHASING" : "CHASING",
	"PATROLLING" : "PATROLLING"
}

var current_state : String 

@export_category("Idle State")
@export var timer_to_patrol : Timer

@export_category("Chase state")
@export var max_chase_distance : float = 1000.0

@export_category("Ground Detector")
@export var ground_checker : RayCast2D

@export_category("Player Checker")
@export var player_checker : RayCast2D
@export var target : Player

func switch_state(new_state : String, event : String):
	if new_state == current_state :
		return 
	
	current_state = new_state
	enemy_state.send_event(event)

func calculate_gravity() :
	velocity.y = clampf(velocity.y, JUMP_VELOCITY, MAX_FALL)

func fall(delta):
	if is_on_floor() == false :
		velocity.y += GRAVITY * delta

func walk():
	if face_direction == FACING.LEFT :
		velocity.x = -WALK_SPEED
	else :
		velocity.x = WALK_SPEED

func chase():
	if face_direction == FACING.LEFT :
		velocity.x = -CHASE_SPEED
	else :
		velocity.x = CHASE_SPEED

func stop():
	velocity.x = 0

func flip():
	ground_checker.position.x = ground_checker.position.x * -1
	player_checker.scale.x = player_checker.scale.x * -1
	animated_sprite.flip_h = !animated_sprite.flip_h
	if face_direction == FACING.LEFT:
		face_direction = FACING.RIGHT
		#animated_sprite.scale.x = -(abs(animated_sprite.scale.x))
	elif face_direction == FACING.RIGHT :
		face_direction = FACING.LEFT
		#animated_sprite.scale.x = (abs(animated_sprite.scale.x))

func check_player():
	if player_checker.is_colliding() == true :
		
		var player : Player = player_checker.get_collider()
		
		if player.is_in_group("Player") == true :
			target = player
			switch_state(STATE_CONTROL.CHASING,STATE_EVENT.PLAYER_ENTERED)

func check_target_distance():
	if global_position.distance_to(target.global_position) > max_chase_distance :
		switch_state(STATE_CONTROL.IDLE ,STATE_EVENT.PLAYER_EXITED)


#region state
func _on_idle_state_entered():
	animated_sprite.play("Idle")
	
	# start patroling if nothing happen
	timer_to_patrol.start(timer_to_patrol.wait_time)

func _on_idle_state_exited():
	animated_sprite.stop()

func _on_idle_state_physics_processing(delta):
	# behaviour pattern
	check_player()
	
	# physics
	fall(delta)
	move_and_slide()
	calculate_gravity()

func _on_chasing_state_entered():
	pass # Replace with function body.

func _on_chasing_state_exited():
	target = null
	stop()

func _on_chasing_state_physics_processing(delta):
	if target == null :
		return
	
	if ((target.global_position.x >= global_position.x && face_direction == FACING.LEFT ) or (target.global_position.x < global_position.x && face_direction == FACING.RIGHT)) && abs(global_position.x - target.global_position.x) > 10.0 :
		flip()
	
	# behaviour pattern
	chase()
	check_target_distance()
	
	# physics
	fall(delta)
	move_and_slide()
	calculate_gravity()

func _on_patroling_state_entered():
	pass # Replace with function body.

func _on_patroling_state_exited():
	pass

func _on_patroling_state_physics_processing(delta):
	if is_on_floor() :
		if is_on_wall() == true or ground_checker.is_colliding() == false:
			flip()
	
	# behaviour pattern
	walk()
	check_player()
	
	# physics
	fall(delta)
	move_and_slide()
	calculate_gravity()
#endregion

func _on_timer_to_patrol_timeout():
	switch_state(STATE_CONTROL.PATROLLING,STATE_EVENT.START_PATROL)
