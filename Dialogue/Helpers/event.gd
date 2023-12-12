extends Area2D

# Custom Dialgoue Balloon with portriats
const Portrait_Balloon = preload("res://Dialogue/Dialogue/portrait_balloon.tscn")
const Cutscene_Balloon = preload("res://Dialogue/Dialogue/cutscene_balloon.tscn")

@export var texture : CompressedTexture2D

@export var automatic : bool = false
@export var event_name : String
@export var event_type : EVENTS

enum EVENTS{ABILITY, OTHER}

# Dialogue file and start positions
@export var dialogue_resource : DialogueResource
@export var dialogue_start : String = "start"

@onready var sprite_2d = $Sprite2D

var player : CharacterBody2D

func _ready():
	if texture:
		sprite_2d.texture = texture

func action() -> void:
	if !automatic:
		# Do event logic
		if dialogue_start == "intro_cutscene":
			#DialogueManager.show_dialogue_balloon(dialogue_resourse, dialogue_start)
			var balloon : Node = Cutscene_Balloon.instantiate()
			get_tree().current_scene.add_child(balloon)
			balloon.start(dialogue_resource, dialogue_start)
		else:
			var balloon : Node = Portrait_Balloon.instantiate()
			get_tree().current_scene.add_child(balloon)
			balloon.start(dialogue_resource, dialogue_start)
		
		SignalManager.dialogue_start.emit()

func _on_body_entered(body):
	if body.is_in_group(&"Player") && body is CharacterBody2D:
		player = body
		if (automatic && event_name && event_type != null):
			match (event_type):
				EVENTS.ABILITY:
					if player.has_method("set_charge"):
						var abilities : Array = player.abilities
						if !abilities.has(event_name):
							player.abilities.append(event_name)
							# Create dialogue balloon
							var balloon : Node = Cutscene_Balloon.instantiate()
							get_tree().current_scene.add_child(balloon)
							balloon.start(dialogue_resource, dialogue_start)
							SignalManager.dialogue_start.emit()
							queue_free()
				EVENTS.OTHER:
					pass
			
				
func _on_body_exited(body):
	if body.is_in_group(&"Player"):
		player = null
