extends BaseEnemy

@export var timer_to_shoot : Timer
var _shoot : bool = false

func _ready():
	health.on_get_damaged.connect(on_get_damaged)
	health.on_dead.connect(on_dead)

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


func _on_timer_to_shoot_timeout():
	_shoot = true
