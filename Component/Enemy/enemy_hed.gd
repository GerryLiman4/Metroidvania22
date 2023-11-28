extends BaseEnemy

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
	super._on_idle_state_exited()

func _on_idle_state_physics_processing(delta):
	super._on_idle_state_physics_processing(delta)

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
	super._on_patroling_state_physics_processing(delta)