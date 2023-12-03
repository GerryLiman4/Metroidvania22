extends Sprite2D

@onready var player : CharacterBody2D
@onready var actionable : Area2D
@onready var sprite = $Sprite2D

@export var npc_name : String
@export var image : CompressedTexture2D

enum FACING{RIGHT,LEFT}
var face_direction
var player_position : Vector2

func _ready():
	# TODO apply texture to AnimatedSprite2D
	sprite.texture = image
	
	sprite.scale = Vector2(0.1, 0.1)
	var sprite_rect : Rect2 = sprite.get_rect()
	sprite.position.y -= sprite_rect.size.y / 50
	
	# TODO Pass Dialogue Resource and Start to Actionable via export?
	var actionable_child : Area2D = get_node("Actionable")
	if actionable_child != null:
		actionable = actionable_child
		actionable_child.connect("body_entered", Callable(self, "_on_area_2d_body_entered"))
		actionable_child.connect("body_exited", Callable(self, "_on_area_2d_body_exited"))
			
func _unhandled_input(event):
	if !(player && actionable):
		return
		
	if Input.is_action_just_pressed("ui_accept"):
		actionable.action()
		
	
func _process(delta):
	#global_position = get_global_mouse_position()
	if !player:		
		return
		
	player_position = (player.global_position - global_position).normalized()
	
	# Handle Player sprite orientation
	if player_position.x > 0:
		face_direction = FACING.RIGHT
		self.flip_h = true
	#elif mouse_direction.x < 0 and not animated_sprite.flip_h:
	elif player_position.x < 0:
		face_direction = FACING.LEFT
		self.flip_h = false

func _on_area_2d_body_entered(body):
	if (body.is_in_group("Player")):
		player = body


func _on_area_2d_body_exited(body):
	if (body.is_in_group("Player")):
		player = null
