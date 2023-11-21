extends CharacterBody2D

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

enum FACING{RIGHT,LEFT}

@export var face_direction : FACING
var dash_timer : float = 0.25
var dash_cooldown_timestamp : float = -1.0
var object_timer : float = 0.0
var is_crawling : bool = false

var can_double_jump : bool = true 

@export_category("Animation")
@export var animation_player : AnimatedSprite2D
@export var body_sprite : Sprite2D
@export var arm_model : Sprite2D
@export var arm_sprite : Sprite2D
@export var head_model : Sprite2D
@export var head_sprite : Sprite2D

@export var bullet_pref : PackedScene
@export var shooter : Node2D
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

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

func _physics_process(delta):
	if is_on_floor() == false :
		velocity.y += GRAVITY * delta
	
	move_and_slide()
	calculate_gravity()

func calculate_gravity() :
	velocity.y = clampf(velocity.y, JUMP_VELOCITY, MAX_FALL)

# get input
func get_move_input() :
	velocity.x = 0
	
	if Input.is_action_pressed("left") == true:
		if is_crawling == false :
			velocity.x = -WALK_SPEED
		else :
			velocity.x = -CRAWL_SPEED
		face_direction = FACING.LEFT
		animation_player.scale.x = (abs(animation_player.scale.x))
		
	elif Input.is_action_pressed("right") == true :
		if is_crawling == false :
			velocity.x = WALK_SPEED
		else :
			velocity.x = CRAWL_SPEED
		
		face_direction = FACING.RIGHT
		animation_player.scale.x = -(abs(animation_player.scale.x))


func get_jump_input() :
	if Input.is_action_pressed("jump") == true and is_on_floor() == true :
		velocity.y = JUMP_VELOCITY
		#SoundManager.play_clip(sound_player,SoundManager.SOUND_JUMP)

func get_dash_input() -> bool :
	if Input.is_action_pressed("dash") == true :
		return true
	else :
		return false

func get_crawl_input() -> bool:
	if Input.is_action_pressed("crawl") == true :
		return true
	else : 
		return false
#endregion

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
	if get_dash_input() == true && object_timer >= dash_cooldown_timestamp + 1.0 :
		return true
	
	return false

func check_crawl() -> bool :
	if get_crawl_input() == true && is_on_floor() == true:
		return true 
	
	return false
	
#end region

#region hand 
func take_aim():
	var aim_position = -get_global_mouse_position()
#	if face_direction == FACING.LEFT :
#		aim_position = -(aim_position)
#
#	var aim_angle = (aim_position - arm_model.global_position).angle()
#	arm_model.rotation = aim_angle
	arm_model.look_at(aim_position)
	
	var bullet : Bullet = bullet_pref.instantiate()
	bullet.global_position = shooter.global_position
	bullet.launch(shooter.global_position - aim_position )
	call_add_child(bullet)

#endregion

#region state
func _on_idle_state_entered():
	can_double_jump = true
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
	
	take_aim()

func _on_idle_state_input(event):
	pass

func _on_walk_state_entered():
	can_double_jump = true
	animation_player.play("Walk")

func _on_walk_state_exited():
	animation_player.stop()

func _on_walk_state_input(event):
	pass

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
	
	take_aim()

func _on_jump_state_entered():
	pass # Replace with function body.

func _on_jump_state_exited():
	pass # Replace with function body.

func _on_jump_state_input(event):
	if can_double_jump == true and Input.is_action_pressed("jump") == true :
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
	
	take_aim()

func _on_fall_state_entered():
	pass # Replace with function body.

func _on_fall_state_exited():
	pass # Replace with function body.

func _on_fall_state_input(event):
	# later if there is double jump
	if can_double_jump == true and Input.is_action_pressed("jump") == true :
		switch_state(CharacterStateId.Id.DOUBLEJUMP)
		return[]

func _on_fall_state_physics_processing(delta):
	if is_on_floor() == true:
		switch_state(CharacterStateId.Id.IDLE)
		return
	
	get_move_input()
	if get_dash_input() == true && object_timer >= dash_cooldown_timestamp + 1.0 :
		switch_state(CharacterStateId.Id.DASH)
		return
	
	take_aim()

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
	dash_cooldown_timestamp = object_timer
	
	if face_direction == FACING.LEFT :
		velocity.x = -DASH_SPEED
	else :
		velocity.x = DASH_SPEED

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
#endregion









