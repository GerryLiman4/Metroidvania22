extends CharacterBody2D

@export var audio_player : AudioStreamPlayer

@export var character_state : StateChart
@export var current_state : CharacterStateId.Id
@export var character_sprite : Sprite2D

const GRAVITY : float = 600.0
const WALK_SPEED : float = 360.0
const MAX_FALL : float = 400.0
const JUMP_VELOCITY : float = -300.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func switch_state(new_state : CharacterStateId.Id) :
	if current_state != null && current_state == new_state:
		return
	
	current_state = new_state
	character_state.send_event(str(CharacterStateId.Id.find_key(new_state)))

func _physics_process(delta):
	if is_on_floor() == false :
		velocity.y += GRAVITY * delta
	
	move_and_slide()
	calculate_gravity()

func get_move_input() :
	velocity.x = 0
	
	if Input.is_action_pressed("left") == true:
		velocity.x = -WALK_SPEED
		character_sprite.flip_h = true
	elif Input.is_action_pressed("right") == true :
		velocity.x = WALK_SPEED
		character_sprite.flip_h = false

func get_jump_input() :
	if Input.is_action_pressed("jump") == true and is_on_floor() == true :
		velocity.y = JUMP_VELOCITY
		#SoundManager.play_clip(sound_player,SoundManager.SOUND_JUMP)

func calculate_gravity() :
	velocity.y = clampf(velocity.y, JUMP_VELOCITY, MAX_FALL)

#region state
func _on_idle_state_entered():
	pass # Replace with function body.

func _on_idle_state_exited():
	pass # Replace with function body.

func _on_idle_state_physics_processing(delta):
	if velocity.x != 0 && is_on_floor() == true:
		switch_state(CharacterStateId.Id.WALK)
	elif velocity.x != 0 && is_on_floor() == false :
		switch_state(CharacterStateId.Id.JUMP)

func _on_idle_state_input(event):
	get_move_input()
	get_jump_input()


func _on_walk_state_entered():
	pass # Replace with function body.

func _on_walk_state_exited():
	pass # Replace with function body.

func _on_walk_state_input(event):
	get_move_input()
	get_jump_input()

func _on_walk_state_physics_processing(delta):
	if velocity.x == 0 && is_on_floor() == true:
		switch_state(CharacterStateId.Id.IDLE)
	elif is_on_floor() == false:
		switch_state(CharacterStateId.Id.JUMP)

func _on_jump_state_entered():
	pass # Replace with function body.

func _on_jump_state_exited():
	pass # Replace with function body.

func _on_jump_state_input(event):
	get_move_input()
	get_jump_input()

func _on_jump_state_physics_processing(delta):
	if is_on_floor() == true:
		switch_state(CharacterStateId.Id.IDLE)
	
#endregion




