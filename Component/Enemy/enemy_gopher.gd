extends BaseEnemy

@export var hitbox : CollisionShape2D
@export var shoot_timer : Timer
@export var flip_timer : Timer
@export var subm : Timer

@export var bullet_scene : PackedScene
@export var shooter : Marker2D

func _ready():
	health.on_get_damaged.connect(on_get_damaged)
	health.on_dead.connect(on_dead)

func on_get_damaged(direction : Vector2):
	pass

func on_dead():
	self.queue_free()

func _on_idle_state_entered():
	animated_sprite.play("Idle")
	
	# start patroling if nothing happen
	flip_timer.start(flip_timer.wait_time)
	hitbox.disabled = true

func _on_idle_state_exited():
	flip_timer.stop()

func _on_idle_state_physics_processing(delta):
	check_player()
	# physics
	fall(delta)
	move_and_slide()
	calculate_gravity()

func _on_chasing_state_entered():
	start_shoot_timer()
	
	animated_sprite.play("Popup")
	hitbox.disabled = false

func _on_chasing_state_exited():
	super._on_chasing_state_exited()
	
	shoot_timer.stop()
	subm.stop()

func _on_chasing_state_physics_processing(delta):
	if target == null :
		return
	
	#behaviour
	if ((target.global_position.x >= global_position.x && face_direction == FACING.LEFT ) or (target.global_position.x < global_position.x && face_direction == FACING.RIGHT)) && abs(global_position.x - target.global_position.x) > 10.0 :
		flip()
	
	check_target_distance()
	
	# physics
	fall(delta)
	move_and_slide()
	calculate_gravity()

func start_shoot_timer() :
	shoot_timer.start(shoot_timer.wait_time)

func _on_shoot_timer_timeout():
	shoot()
	animated_sprite.play("Idle")
	hitbox.disabled = true
	subm.start(subm.wait_time)

func _on_submerge_timer_timeout():
	subm.stop()
	animated_sprite.play("Popup")
	hitbox.disabled = false
	start_shoot_timer()

func shoot():
	var direction : Vector2
	
	if target == null :
		return 
	
	direction = (target.global_position - global_position).normalized()
	
	await get_tree().create_timer(0.15)
	
	var bullet : Bullet = bullet_scene.instantiate()
	bullet.global_position = shooter.global_position
	bullet.launch(shooter.global_position, direction , 400)
	get_tree().root.add_child(bullet);

func start_flip_timer() :
	flip_timer.start(flip_timer.wait_time)

func _on_flip_timer_timeout():
	flip()

func flip():
	ground_checker.position.x = ground_checker.position.x * -1
	player_checker.scale.x = player_checker.scale.x * -1
	animated_sprite.flip_h = !animated_sprite.flip_h
	if face_direction == FACING.LEFT:
		face_direction = FACING.RIGHT
		shooter.position.x = (abs(shooter.position.x))
	elif face_direction == FACING.RIGHT :
		face_direction = FACING.LEFT
		shooter.position.x = -(abs(shooter.position.x))

