# A portal object that transports to another world layer.
extends Area2D
# The target map after entering the portal.
@export var target_map: String

@onready var label = $Label

var player

func _ready():
	label.visible = false

func action() -> void:
	# If player entered and isn't doing an event (event in this case is entering the portal).
	#if body.is_in_group(&"Player") and not body.event:
	if player:
		#body.event = true
		player.velocity = Vector2()
		# Tween the player position into the portal.
		var tween := create_tween()
		tween.tween_property(player, ^"position", position, 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
		await tween.finished
		# After tween finished, change the map.
		Game.get_singleton().travelto_map(MetSys.get_full_room_path(target_map))
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
