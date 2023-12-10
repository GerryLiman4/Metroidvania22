extends Area2D
# The target map after entering the elevators.
@export var target_map: String
@export var texture : Texture

@onready var sprite_2d = $Sprite2D
@onready var animation_player = $Sprite2D/AnimationPlayer

@onready var label = $Label

var player

func _ready():
	if texture:
		sprite_2d.texture = texture
		
	animation_player.play("RESET")

func action() -> void:
	if player:
		player.velocity = Vector2()
		# Play animation
		animation_player.play("Open")
		SceneTransition.transition()
		
func goto_map() -> void:
	# After tween finished, change the map.
		Game.get_singleton().goto_map(MetSys.get_full_room_path(target_map), true)
		# A trick to reset player's event variable when it's safe to do so (i.e. after some frames).
		get_tree().create_timer(0.05).timeout.connect(player.set.bind(&"event", false))
		# Delta vector feature again.
		Game.get_singleton().reset_map_starting_coords()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(&"Player"):
		player = body
		label.visible = true


func _on_body_exited(body):
	if body.is_in_group(&"Player"):
		player = null
		label.visible = false
