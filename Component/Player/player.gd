extends CharacterBody2D

class_name Player

@onready var actionable_finder = $AnimatedSprite2D/Direction/ActionableFinder

@export var audio_player : AudioStreamPlayer

@export var character_state : StateChart
@export var current_state : CharacterStateId.Id

const GRAVITY : float = 600.0
const WALK_SPEED : float = 360.0
const MAX_FALL : float = 400.0
const JUMP_VELOCITY : float = -350.0
const CRAWL_SPEED : float = 180.0
const DASH_SPEED : float = 1200.0
const DOUBLE_JUMP_VELOCITY : float = -350.0
const DASH_COOLDOWN : float = 1.0
const WALL_JUMP_VELOCITY : Vector2 = Vector2(550.0,-250.0)

enum FACING{RIGHT,LEFT}

@export var face_direction : FACING
@export var wall_latch : FACING
@export var wall_jump_timer : Timer

var dash_timer : float = 0.25
var dash_cooldown_timestamp : float = -1.0

var object_timer : float = 0.0

var is_crawling : bool = false

var can_double_jump : bool = true 

var reset_position : Vector2

@export_category("Animation")
@export var animation_player : AnimatedSprite2D
@export var body_sprite : Sprite2D
@export var arm_model : Sprite2D
@export var arm_sprite : Sprite2D
@export var head_model : Sprite2D
@export var head_sprite : Sprite2D

@export_category("Shooter")
@export var bullet_pref : PackedScene
@export var shooter : Node2D

@export_category("Health")
@export var player_health : Health

# Called when the node enters the scene tree for the first time.
func _ready():
	player_health.on_get_damaged.connect(on_get_damaged)
	player_health.on_dead.connect(on_dead)

func _unhandled_input(_event : InputEvent) -> void:
	if Input.is_action_just_pressed("y"):
		var actionables = actionable_finder.get_overlapping_areas()
		if actionables.size() > 0:
			actionables[0].action()
			return
	if Input.is_action_just_pressed("start"):
		SceneTransition.start_transition_to("menu", true, "res://UI/main.tscn")

func on_enter():
	# Position for kill system. Assigned when entering new room (see Game.gd).
	reset_position = position

func add_child_deferred(child_to_add) -> void :
	get_tree().root.add_child(child_to_add)

func call_add_child(child_to_add) -> void :
	call_deferred("add_child_deferred",child_to_add)

func switch_state(new_state : CharacterStateId.Id) :
	if current_state != null && current_state == new_state:
		return
	
	current_state = new_state
	character_state.send_event(str(CharacterStateId.Id.find_key(new_state)))

func _process(delta):
	object_timer += delta
	var mouse_direction : Vector2 = (get_global_mouse_position() - global_position).normalized()
	
	# Handle Player sprite orientation
	if mouse_direction.x > 0:
		face_direction = FACING.RIGHT
		animation_player.scale.x = -(abs(animation_player.scale.x))
		$ArmModel.flip_h = true
	#elif mouse_direction.x < 0 and not animated_sprite.flip_h:
	elif mouse_direction.x < 0:
		face_direction = FACING.LEFT
		animation_player.scale.x = (abs(animation_player.scale.x))
		$ArmModel.flip_h = false
		
	take_aim(mouse_direction)

func _physics_process(delta):
	if is_on_floor() == false :
		velocity.y += GRAVITY * delta
	
	if is_on_floor() == true :
		can_double_jump = true
	
	move_and_slide()
	calculate_gravity()

func calculate_gravity() :
	velocity.y = clampf(velocity.y, JUMP_VELOCITY, MAX_FALL)

# get input
func get_move_input() :
	velocity.x = 0
	
	if Input.is_action_pressed("move_left") == true:
		if is_crawling == false :
			velocity.x = -WALK_SPEED
		else :
			velocity.x = -CRAWL_SPEED
		
		
	elif Input.is_action_pressed("move_right") == true :
		if is_crawling == false :
			velocity.x = WALK_SPEED
		else :
			velocity.x = CRAWL_SPEED
		
		

func get_jump_input() :
	if Input.is_action_pressed("a") == true and is_on_floor() == true :
		velocity.y = JUMP_VELOCITY
		#SoundManager.play_clip(sound_player,SoundManager.SOUND_JUMP)

func get_dash_input() -> bool :
	if Input.is_action_pressed("x") == true :
		return true
	else :
		return false

func get_crawl_input() -> bool:
	if Input.is_action_pressed("b") == true :
		return true
	else : 
		return false
#endregion

func on_get_damaged(direction : Vector2) :
	pass

func on_dead():
	pass

#region check state

func check_idle() -> bool :
	if velocity.x == 0 && is_on_floor() == true:
		return true
	
	return false

func check_walk() -> bool :
	if velocity.x != 0 && is_on_floor() == true:
		return true
	
	return false

func check_jump() -> bool :
	if velocity.y < 0 && is_on_floor() == false :
		return true
	
	return false

func check_fall() -> bool :
	if velocity.y > 0 && is_on_floor() == false :
		return true
	
	return false

func check_dash() -> bool :
	if get_dash_input() == true && object_timer >= dash_cooldown_timestamp + DASH_COOLDOWN :
		return true
	
	return false

func check_crawl() -> bool :
	if get_crawl_input() == true && is_on_floor() == true:
		return true 
	
	return false

func check_latch() -> bool :
	if is_on_wall_only() == true:
		match get_which_wall_collided() :
			"left" :
				if Input.is_action_pressed("left") :
					wall_latch = FACING.LEFT
					return true
			"right" :
				if Input.is_action_pressed("right")  :
					wall_latch = FACING.RIGHT
					return true
			"none" :
				return false
	
	return false

func get_which_wall_collided() -> String:
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision.get_normal().x > 0:
			return "left"
		elif collision.get_normal().x < 0:
			return "right"
	return "none"
#endregion

#region hand 
func take_aim(aim_position):
	aim_position = -aim_position
	arm_model.rotation = aim_position.angle()
	if face_direction == FACING.RIGHT :
		$AnimatedSprite2D/Arm.rotation_degrees = -(arm_model.rotation_degrees - PI * 172)
	else:
		$AnimatedSprite2D/Arm.rotation_degrees = arm_model.rotation_degrees
	
	if Input.is_action_just_pressed("right_trigger") == true : 
		var bullet : Bullet = bullet_pref.instantiate()
		bullet.global_position = shooter.global_position
		bullet.launch($AnimatedSprite2D/Arm/Marker2D.global_position, Vector2.LEFT.rotated(deg_to_rad(arm_model.rotation_degrees)), 2000)
		call_add_child(bullet)

#endregion

#region state
func _on_idle_state_entered():
	animation_player.play("Idle")

func _on_idle_state_exited():
	animation_player.stop()

func _on_idle_state_physics_processing(delta):
	if check_walk() == true:
		switch_state(CharacterStateId.Id.WALK)
		return
	elif check_jump() == true:
		switch_state(CharacterStateId.Id.JUMP)
		return
	elif check_fall() == true :
		switch_state(CharacterStateId.Id.FALL)
		return
	elif check_crawl() == true :
		switch_state(CharacterStateId.Id.CRAWL)
		return
	
	get_move_input()
	get_jump_input()
	if check_dash() == true :
		switch_state(CharacterStateId.Id.DASH)
		return
	

func _on_idle_state_input(event):
	pass

func _on_walk_state_entered():
	can_double_jump = true
	animation_player.play("Walk")

func _on_walk_state_exited():
	animation_player.stop()

func _on_walk_state_input(event):
	pass

func _on_walk_state_processing(delta):
	if (face_direction == FACING.LEFT && velocity.x > 0 ) or (face_direction == FACING.RIGHT && velocity.x < 0 ): 
		if animation_player.animation == "Walk" :
			animation_player.play("WalkBackward")
	else :
		if animation_player.animation == "WalkBackward" :
			animation_player.play("Walk")

func _on_walk_state_physics_processing(delta):
	if check_idle() == true:
		switch_state(CharacterStateId.Id.IDLE)
		return
	elif check_jump() == true:
		switch_state(CharacterStateId.Id.JUMP)
		return
	elif check_fall() == true :
		switch_state(CharacterStateId.Id.FALL)
		return
	elif check_crawl() == true :
		switch_state(CharacterStateId.Id.CRAWL)
		return
	
	get_move_input()
	get_jump_input()
	if check_dash() == true :
		switch_state(CharacterStateId.Id.DASH)
		return

func _on_jump_state_entered():
	pass # Replace with function body.

func _on_jump_state_exited():
	pass # Replace with function body.

func _on_jump_state_input(event):
	if can_double_jump == true and Input.is_action_just_pressed("a") == true :
		switch_state(CharacterStateId.Id.DOUBLEJUMP)
		return

func _on_jump_state_physics_processing(delta):
	get_move_input()
	if check_dash() == true :
		switch_state(CharacterStateId.Id.DASH)
		return
	
	if check_fall() == true :
		switch_state(CharacterStateId.Id.FALL)
		return

func _on_fall_state_entered():
	pass # Replace with function body.

func _on_fall_state_exited():
	pass # Replace with function body.

func _on_fall_state_input(event):
	# later if there is double jump
	if can_double_jump == true and Input.is_action_just_pressed("a") == true :
		switch_state(CharacterStateId.Id.DOUBLEJUMP)
		return[]

func _on_fall_state_physics_processing(delta):
	if is_on_floor() == true:
		switch_state(CharacterStateId.Id.IDLE)
		return
	
	get_move_input()
	if get_dash_input() == true && object_timer >= dash_cooldown_timestamp + DASH_COOLDOWN :
		switch_state(CharacterStateId.Id.DASH)
		return
	
	# check wall latch
	if check_latch() == true :
		switch_state(CharacterStateId.Id.WALLLATCH)

func _on_double_jump_state_entered():
	can_double_jump = false
	if velocity.y > 0 : 
		velocity.y = DOUBLE_JUMP_VELOCITY
	else :
		velocity.y += DOUBLE_JUMP_VELOCITY

func _on_double_jump_state_exited():
	pass

func _on_double_jump_state_input(event):
	pass # Replace with function body.

func _on_double_jump_state_physics_processing(delta):
	get_move_input()
	
	if check_fall() == true :
		switch_state(CharacterStateId.Id.FALL)
		return


func _on_crawl_state_entered():
	is_crawling = true
	pass # Replace with function body.

func _on_crawl_state_exited():
	# on exit return collider to normal size
	is_crawling = false
	pass # Replace with function body.

func _on_crawl_state_input(event):
	pass # Replace with function body.

func _on_crawl_state_physics_processing(delta):
	if check_crawl() == false :
		switch_state(CharacterStateId.Id.IDLE)
		return
	
	get_move_input()


func _on_dash_state_entered():
	# set timestamp for cooldown
	dash_cooldown_timestamp = object_timer
	
	if face_direction == FACING.LEFT :
		velocity.x = -DASH_SPEED
	else :
		velocity.x = DASH_SPEED
	
	SignalManager.player_dash.emit(DASH_COOLDOWN)

func _on_dash_state_exited():
	dash_timer = 0.25
	pass # Replace with function body.

func _on_dash_state_input(event):
	pass # Replace with function body.

func _on_dash_state_physics_processing(delta):
	dash_timer -= delta
	velocity.y = 0
	
	if dash_timer <= 0 :
		velocity.x = 0
		switch_state(CharacterStateId.Id.IDLE) 
		return



func _on_wall_latch_state_entered():
	velocity = Vector2.ZERO
	set_physics_process(false)

func _on_wall_latch_state_exited():
	# should flip 
	set_physics_process(true)
	pass


func _on_wall_latch_state_input(event):
	#if wall_latch == FACING.LEFT :
		#if Input.is_action_pressed("left") == false or Input.is_action_pressed("right"):
			#switch_state(CharacterStateId.Id.IDLE)
	#elif wall_latch == FACING.RIGHT :
		#if Input.is_action_pressed("right") == false or Input.is_action_pressed("left") :
			#switch_state(CharacterStateId.Id.IDLE)
	
	if Input.is_action_just_pressed("crawl") :
		switch_state(CharacterStateId.Id.IDLE)
	
	if Input.is_action_just_pressed("dash") :
		switch_state(CharacterStateId.Id.DASH)
	
	if Input.is_action_just_pressed("jump") :
		switch_state(CharacterStateId.Id.WALLJUMP)

func _on_wall_latch_state_physics_processing(delta):
	#velocity = Vector2.ZERO
	move_and_slide()


func _on_wall_jump_state_entered():
	var true_velocity = WALL_JUMP_VELOCITY
	
	if wall_latch == FACING.RIGHT:
		true_velocity.x *= -1 
	
	velocity = true_velocity
	wall_jump_timer.start(wall_jump_timer.wait_time)

func _on_wall_jump_state_exited():
	velocity = Vector2.ZERO
	wall_jump_timer.stop()

func _on_wall_jump_state_input(event):
	pass # Replace with function body.

func _on_wall_jump_state_physics_processing(delta):
	pass # Replace with function body.

#endregion

func _on_wall_jump_timer_timeout():
	switch_state(CharacterStateId.Id.IDLE)






