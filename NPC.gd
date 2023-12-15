extends CharacterBody2D

@export var npc_name : String
@export var image : CompressedTexture2D

@export var face_direction : FACING
enum FACING{RIGHT,LEFT}

@onready var actionable : Area2D
@onready var sprite = $Sprite2D

var player_position : Vector2

var player = null

func _ready():
	# TODO apply texture to AnimatedSprite2D
	if image:
		sprite.texture = image
	
	await get_tree().create_timer(.1).timeout
	# Remove miner from abyss & add to surface if rescued
	if npc_name == "Miner" || npc_name == "Criss Cross Ross":
		var game = Game.get_singleton()
		match npc_name:
			"Miner":
				if game.events.has("miner_intro"):
					queue_free()
			"Criss Cross Ross":
				if !game.events.has("miner_intro"):
					queue_free()

func _unhandled_input(event):
	if !(player && actionable):
		return
		
	if Input.is_action_just_pressed("ui_accept"):
		actionable.action()
	
func _process(delta):
	#global_position = get_global_mouse_position()
	if player:
		var player_position = (player.global_position - self.global_position).normalized()
		# Handle Player sprite orientation
		if player_position.x > 0:
			face_direction = FACING.RIGHT
		#elif mouse_direction.x < 0 and not animated_sprite.flip_h:
		elif player_position.x < 0:
			face_direction = FACING.LEFT
		
	if face_direction == FACING.RIGHT:
		sprite.flip_h = true
	elif face_direction == FACING.LEFT:
		sprite.flip_h = false

func _on_actionable_body_entered(body):
	if (body.is_in_group("Player")):
		player = body


func _on_actionable_body_exited(body):
	if (body.is_in_group("Player")):
		player = null
