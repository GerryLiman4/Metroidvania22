extends CharacterBody2D

@onready var player : CharacterBody2D
@onready var actionable : Area2D
@onready var sprite_2d = $Sprite2D
#@onready var animated_sprite = $AnimatedSprite2D

@export var npc_name : String
@export var texture : CompressedTexture2D

enum FACING{RIGHT,LEFT}
var face_direction
var player_position : Vector2

func _ready():
	# TODO apply texture to AnimatedSprite2D
	sprite_2d.texture = texture
	
	var sprite_rect : Rect2 = sprite_2d.get_rect()
	sprite_2d.position.y -= sprite_rect.size.y / 2.3
	
	# TODO Pass Dialogue Resource and Start to Actionable via export?
	
		

func _process(delta):
	#global_position = get_global_mouse_position()
	if !player:		
		return
		
	player_position = (player.global_position - global_position).normalized()
	
	# Handle Player sprite orientation
	if player_position.x > 0:
		face_direction = FACING.RIGHT
		sprite_2d.flip_h = true
	#elif mouse_direction.x < 0 and not animated_sprite.flip_h:
	elif player_position.x < 0:
		face_direction = FACING.LEFT
		sprite_2d.flip_h = false

func _on_area_2d_area_entered(area):
	pass


func _on_area_2d_body_entered(body):
	if (body.is_in_group("Player")):
		player = body


func _on_area_2d_body_exited(body):
	if (body.is_in_group("Player")):
		player = null
