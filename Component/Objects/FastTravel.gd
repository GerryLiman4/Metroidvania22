extends Area2D
# The target map after entering the elevators.
@export var target_map: String
@export var texture : Texture
@export var id : int

const Cutscene_Balloon = preload("res://Dialogue/Dialogue/cutscene_balloon.tscn")

@export var dialogue_resource : DialogueResource = preload("res://Dialogue/Dialogue/event.dialogue")

@onready var sprite_2d = $Sprite2D
@onready var animation_player = $Sprite2D/AnimationPlayer

@onready var use_label = $UseLabel

var player

var is_active : bool = false

func _ready():
	if texture:
		sprite_2d.texture = texture
		
	animation_player.play("RESET")
	'''
	if Game.get_singleton().events.has("lift_active"):
		is_active = true
		use_label.visible = false
		fix_label.visible = false
	'''

func action() -> void:
	if player:
		var player_ref = Player.get_singleton()
		var game = Game.get_singleton()
		match id:
			0:
				if game.events.has("lift_active"):
					player.velocity = Vector2()
					# Play animation
					animation_player.play("Open")
					SceneTransition.transition()
					player.event = true
				else:
					var balloon : Node = Cutscene_Balloon.instantiate()
					get_tree().current_scene.add_child(balloon)
					balloon.start(dialogue_resource, "elevator")
					SignalManager.dialogue_start.emit()
			1:
				if game.events.has("lift_active"):
					player.velocity = Vector2()
					# Play animation
					animation_player.play("Open")
					SceneTransition.transition()
					player.event = true
				else:
					game.events.append("lift_active")
					var balloon : Node = Cutscene_Balloon.instantiate()
					get_tree().current_scene.add_child(balloon)
					balloon.start(dialogue_resource, "elevator_fixed")
					SignalManager.dialogue_start.emit()
					
							
		
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
		
		use_label.visible = true



func _on_body_exited(body : Node2D) -> void:
	if body.is_in_group(&"Player"):
		player = null
		use_label.visible = false
