extends BaseEnemy

@export var jump_velocity : Vector2 = Vector2(100,-150)
@export var jump_timer : Timer

@onready var audio_stream_player : AudioStreamPlayer  = $AudioStreamPlayer
@onready var hitbox = $Hitbox/hitbox

var _jump : bool = false
var is_dead : bool = false
var audioScenes := {
	"spider_screech1" : preload("res://Resources/Audio/SFX/Enemy/Spider/Spidernoises-001.ogg"),
	"spider_screech2" : preload("res://Resources/Audio/SFX/Enemy/Spider/Spidernoises-004.ogg"),
	"spider_hurt1" : preload("res://Resources/Audio/SFX/Enemy/Enemy-003.ogg"),
	"spider_hurt2" : preload("res://Resources/Audio/SFX/Enemy/Enemy-005.ogg")
}

func _ready():
	health.on_get_damaged.connect(on_get_damaged)
	health.on_dead.connect(on_dead)

func on_get_damaged(direction : Vector2):
	var enemyHurtSFXKeys := ["spider_screech1", "spider_screech2"]
	var randomKey = enemyHurtSFXKeys[randi() % enemyHurtSFXKeys.size() - 1]
	
	if randomKey in audioScenes && audio_stream_player.playing == false:
		audio_stream_player.stream = audioScenes[randomKey]
		audio_stream_player.pitch_scale = randf_range(0.9, 1.1)
		audio_stream_player.play()
		#await audio_stream_player.finished
	else:
		print(randomKey + " not found in audioScenes, or SFX already playing")

func on_dead():
	if is_dead == true : 
		return
	
	stop()
	velocity.y = 0
	hitbox.set_deferred("disabled", true)
	is_dead = true 
	
	var enemyDeadSFXKeys := ["spider_hurt1", "spider_hurt2"]
	var randomKey = enemyDeadSFXKeys[randi() % enemyDeadSFXKeys.size() - 1]
	
	if randomKey in audioScenes:
		audio_stream_player.stream = audioScenes[randomKey]
		audio_stream_player.pitch_scale = randf_range(0.9, 1.1)
		audio_stream_player.play()
		#await audio_stream_player.finished
	else:
		print(randomKey + " not found in audioScenes")
		
	animated_sprite.play("Dead")
	await animated_sprite.animation_finished
	self.queue_free()

func jump():
	if is_dead == true : 
		return
		
	if is_on_floor() == false :
		return
	
	if  _jump == false : 
		return
	
	if is_on_floor() :
		if is_on_wall() == true or ground_checker.is_colliding() == false:
			flip()
			
	velocity = jump_velocity
	
	if face_direction == FACING.LEFT :
		velocity.x = velocity.x * -1
	
	_jump = false
	
	animated_sprite.play("Jump")
	
	start_timer()

func calculate_gravity() :
	velocity.y = clampf(velocity.y, JUMP_VELOCITY, MAX_FALL)

func _on_idle_state_entered():
	if is_dead == true : 
		return
	animated_sprite.play("Idle")
	
	# start patroling if nothing happen
	timer_to_patrol.start(timer_to_patrol.wait_time)

func _on_idle_state_exited():
	pass

func _on_idle_state_physics_processing(delta):
	if is_dead == true :
		return
	
	if health.health_point <= 0 :
		return
	
	super._on_idle_state_physics_processing(delta)

func _on_chasing_state_entered():
	start_timer()

func _on_chasing_state_exited():
	super._on_chasing_state_exited()

func _on_chasing_state_physics_processing(delta):
	if is_dead == true : 
		return
		
	if health.health_point <= 0 :
		return
	
	if target == null :
		return
	
	if ((target.global_position.x >= global_position.x && face_direction == FACING.LEFT ) or (target.global_position.x < global_position.x && face_direction == FACING.RIGHT)) && abs(global_position.x - target.global_position.x) > 10.0 :
		flip()
	
	check_target_distance()
	
	# physics
	fall(delta)
	
	if is_on_floor() == true :
		velocity.x = 0
		if animated_sprite.animation != "Idle" :
			animated_sprite.play("Idle")
	
	jump()
	
	move_and_slide()
	calculate_gravity()


func _on_patroling_state_entered():
	start_timer()

func _on_patroling_state_exited():
	pass # Replace with function body.

func _on_patroling_state_physics_processing(delta):
	if is_dead == true : 
		return
	
	if health.health_point <= 0 :
		return
	
	# behaviour pattern
	check_player()
	
	# physics
	if is_on_floor() == true :
		velocity.x = 0
	if animated_sprite.animation != "Idle" :
			animated_sprite.play("Idle")
	
	jump()
	
	fall(delta)
	move_and_slide()
	calculate_gravity()

func start_timer() :
	jump_timer.start(jump_timer.wait_time)

func _on_jump_timer_timeout():
	_jump = true
