extends BaseEnemy

const GRAVITY : float = 700.0
const MAX_FALL : float = 400.0
const JUMP_VELOCITY : float = -350.0

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
	animated_sprite.play("Idle")

func _on_idle_state_exited():
	animated_sprite.stop()

func _on_idle_state_physics_processing(delta):
	if is_on_floor() == false :
		velocity.y += GRAVITY * delta
	
	move_and_slide()
	calculate_gravity()

func _on_chasing_state_entered():
	pass # Replace with function body.

func _on_chasing_state_exited():
	pass # Replace with function body.

func _on_chasing_state_physics_processing(delta):
	pass # Replace with function body.


func _on_patroling_state_entered():
	pass # Replace with function body.

func _on_patroling_state_exited():
	pass # Replace with function body.

func _on_patroling_state_physics_processing(delta):
	pass # Replace with function body.
