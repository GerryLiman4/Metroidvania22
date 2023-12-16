extends BaseEnemy

@export var timer_to_shoot : Timer
@export var bullet_scene : PackedScene
@export var shooter : Node2D
var _can_shoot : bool = false
@onready var audio_stream_player = $AudioStreamPlayer2D
@onready var collision_shape_2d = $Hitbox/CollisionShape2D
var is_dead : bool = false
var audioScenes := {
	"attack1" : preload("res://Resources/Audio/SFX/Enemy/Slime/slime_attack-001.ogg"),
	"attack2" : preload("res://Resources/Audio/SFX/Enemy/Slime/slime_attack-004.ogg"),
	"dead" : preload("res://Resources/Audio/SFX/Enemy/Enemy-003.ogg"),
}


func _ready():
	health.on_get_damaged.connect(on_get_damaged)
	health.on_dead.connect(on_dead)

func _shoot():
	var direction : Vector2
	
	if target == null or _can_shoot == false:
		return 
	
	direction = (target.global_position - global_position).normalized()
	
	await get_tree().create_timer(0.15)
	
	#region SFX
	var enemyHurtSFXKeys := ["attack1", "attack2"]
	var randomKey = enemyHurtSFXKeys[randi() % enemyHurtSFXKeys.size()]
	
	if randomKey in audioScenes && audio_stream_player.playing == false:
		audio_stream_player.stream = audioScenes[randomKey]
		audio_stream_player.pitch_scale = randf_range(0.9, 1.1)
		audio_stream_player.play()
	#endregion
	
	var bullet : Bullet = bullet_scene.instantiate()
	bullet.global_position = shooter.global_position
	bullet.launch(shooter.global_position, direction , 400)
	get_tree().root.add_child(bullet);

func on_get_damaged(direction : Vector2):
	return

func on_dead():
	if is_dead == true : 
		return
	
	stop()
	velocity.y = 0
	collision_shape_2d.set_deferred("disabled", true)
	is_dead = true 
	
	animated_sprite.play("Dead")
	if audioScenes["dead"]:
		audio_stream_player.stream = audioScenes["dead"]
		audio_stream_player.pitch_scale = randf_range(0.9, 1.1)
		audio_stream_player.play()
	await animated_sprite.animation_finished
	
	self.queue_free()
	
func calculate_gravity() :
	velocity.y = clampf(velocity.y, JUMP_VELOCITY, MAX_FALL)

func _on_idle_state_entered():
	super._on_idle_state_entered()

func _on_idle_state_exited():
	pass

func _on_idle_state_physics_processing(delta):
	if is_dead == true :
		return
	super._on_idle_state_physics_processing(delta)

func _on_chasing_state_entered():
	animated_sprite.play("Walk")
	
	timer_to_shoot.start(timer_to_shoot.wait_time)

func _on_chasing_state_exited():
	pass

func _on_chasing_state_physics_processing(delta):
	if is_dead == true :
		return
	
	if target == null :
		return
	
	if ((target.global_position.x >= global_position.x && face_direction == FACING.LEFT ) or (target.global_position.x < global_position.x && face_direction == FACING.RIGHT)) && abs(global_position.x - target.global_position.x) > 10.0 :
		flip()
	
	# behaviour pattern
	chase()
	check_target_distance()
	
	if _can_shoot == true :
		switch_state(STATE_CONTROL.SHOOTING, STATE_EVENT.SHOOT)
	
	# physics
	fall(delta)
	move_and_slide()
	calculate_gravity()

func _on_patroling_state_entered():
	animated_sprite.play("Walk")

func _on_patroling_state_exited():
	pass # Replace with function body.

func _on_patroling_state_physics_processing(delta):
	if is_dead == true :
		return
	
	if is_on_wall() == true or ground_checker.is_colliding() == false:
		flip()
	
	# behaviour pattern
	walk()
	check_player()
	
	# physics
	fall(delta)
	move_and_slide()
	calculate_gravity()

func _on_shooting_state_entered():
	brake()
	animated_sprite.play("Shoot")
	
	call_deferred("_shoot")

func _on_shooting_state_exited():
	pass # Replace with function body.

func _on_shooting_state_physics_processing(delta):
	# physics
	fall(delta)
	move_and_slide()
	calculate_gravity()

func _on_timer_to_shoot_timeout():
	_can_shoot = true

func _on_animated_sprite_2d_animation_finished():
	if animated_sprite.animation == "Shoot" :
		_can_shoot = false
		switch_state(STATE_CONTROL.CHASING,STATE_EVENT.PLAYER_ENTERED)
