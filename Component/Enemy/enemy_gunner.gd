extends BaseEnemy

@export var timer_to_shoot : Timer
@export var bullet_scene : PackedScene
@export var shooter : Node2D
var _can_shoot : bool = false

func _ready():
	health.on_get_damaged.connect(on_get_damaged)
	health.on_dead.connect(on_dead)

func _shoot():
	var direction : Vector2
	
	if target == null or _can_shoot == false:
		return 
	
	direction = (target.global_position - global_position).normalized()
	
	await get_tree().create_timer(0.15)
	
	var bullet : Bullet = bullet_scene.instantiate()
	bullet.global_position = shooter.global_position
	bullet.launch(shooter.global_position, direction , 400)
	get_tree().root.add_child(bullet);

func on_get_damaged(direction : Vector2):
	return

func on_dead():
	self.queue_free()
	
func calculate_gravity() :
	velocity.y = clampf(velocity.y, JUMP_VELOCITY, MAX_FALL)

func _on_idle_state_entered():
	super._on_idle_state_entered()

func _on_idle_state_exited():
	pass

func _on_idle_state_physics_processing(delta):
	super._on_idle_state_physics_processing(delta)

func _on_chasing_state_entered():
	animated_sprite.play("Walk")
	
	timer_to_shoot.start(timer_to_shoot.wait_time)

func _on_chasing_state_exited():
	pass

func _on_chasing_state_physics_processing(delta):
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