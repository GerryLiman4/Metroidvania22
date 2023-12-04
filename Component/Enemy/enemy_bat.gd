extends BaseEnemy

@export var navigation_agent : NavigationAgent2D
@export var accel_speed : int = 10

@onready var audio_stream_player = $AudioStreamPlayer

var audioScenes := {
	"bat_screech1" : preload("res://Resources/Audio/SFX/Enemy/Bat/Batnoise-001.ogg"),
	"bat_screech2" : preload("res://Resources/Audio/SFX/Enemy/Bat/Batnoise-001.ogg"),
	"bat_dead1" : preload("res://Resources/Audio/SFX/Enemy/Enemy-001.ogg"),
	"bat_dead2" : preload("res://Resources/Audio/SFX/Enemy/Enemy-001.ogg")
}


func _ready():
	health.on_get_damaged.connect(on_get_damaged)
	health.on_dead.connect(on_dead)

func on_get_damaged(direction : Vector2):
	var enemyHurtSFXKeys := ["bat_screech1", "bat_screech2"]
	var randomKey = enemyHurtSFXKeys[randi() % enemyHurtSFXKeys.size()]
	
	if randomKey in audioScenes && audio_stream_player.playing == false:
		audio_stream_player.stream = audioScenes[randomKey]
		audio_stream_player.pitch_scale = randf_range(0.9, 1.1)
		audio_stream_player.play()
		await audio_stream_player.finished
	else:
		print(randomKey + " not found in audioScenes, or SFX already playing")

func on_dead():
	var enemyDeadSFXKeys := ["bat_dead1", "bat_dead2"]
	var randomKey = enemyDeadSFXKeys[randi() % enemyDeadSFXKeys.size()]
	
	if randomKey in audioScenes:
		audio_stream_player.stream = audioScenes[randomKey]
		audio_stream_player.pitch_scale = randf_range(0.9, 1.1)
		audio_stream_player.play()
		await audio_stream_player.finished
	else:
		print(randomKey + " not found in audioScenes")
	self.queue_free()
		
	
func calculate_gravity() :
	velocity.y = clampf(velocity.y, JUMP_VELOCITY, MAX_FALL)

func _on_idle_state_entered():
	super._on_idle_state_entered()

func _on_idle_state_exited():
	super._on_idle_state_exited()

func _on_idle_state_physics_processing(delta):
	move_and_slide()

func _on_chasing_state_entered():
	animated_sprite.play("Fly")

func _on_chasing_state_exited():
	pass
	

func _on_chasing_state_physics_processing(delta):
	if target == null :
		return
	
	var direction = Vector2()
	
	navigation_agent.target_position = target.global_position
	
	direction = navigation_agent.get_next_path_position() - global_position
	direction = direction.normalized()
	
	velocity = velocity.lerp(direction * CHASE_SPEED,accel_speed * delta )
	# physics
	move_and_slide()


func _on_patroling_state_entered():
	animated_sprite.play("Fly")

func _on_patroling_state_exited():
	pass # Replace with function body.

func _on_patroling_state_physics_processing(delta):
	if is_on_wall() == true :
		flip()
	
	# behaviour pattern
	walk()
	
	# physics
	move_and_slide()

func _on_visible_on_screen_notifier_2d_screen_entered():
	switch_state(STATE_CONTROL.CHASING,STATE_EVENT.PLAYER_ENTERED)
