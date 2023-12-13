extends Area2D

# Custom Dialgoue Balloon with portriats
const Portrait_Balloon = preload("res://Dialogue/Dialogue/portrait_balloon.tscn")
const Cutscene_Balloon = preload("res://Dialogue/Dialogue/cutscene_balloon.tscn")

@export var texture : CompressedTexture2D

@export var automatic : bool = false
@export var event_name : String
@export var event_type : EVENTS

enum EVENTS{ABILITY, OTHER}

@onready var ability_sprite = $AbilitySprite
@onready var sprite_2d = $Sprite2D

# Dialogue file and start positions
@export var dialogue_resource : DialogueResource
@export var dialogue_start : String = "start"



var player : CharacterBody2D

func _ready():
	if event_type == EVENTS.ABILITY:
		ability_sprite.play("default")
		ability_sprite.show()
		sprite_2d.hide()
	elif texture:
		sprite_2d.texture = texture
		sprite_2d.show()
		ability_sprite.hide()
		ability_sprite.stop()
	
	player = get_parent().get_node_or_null("Player")
	
	match event_type:
		EVENTS.ABILITY:
			if Player.get_singleton().abilities.has(event_name):
				self.visible = false
		EVENTS.OTHER:
			if event_name == "end_cutscene":
				sprite_2d.hide()
				ability_sprite.hide()
				

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
	if body.is_in_group(&"Player"):
		player = body
		if (automatic && event_name && event_type != null):
			match (event_type):
				EVENTS.ABILITY:
					if !Player.get_singleton().abilities.has(event_name):
						var abilities : Array = player.abilities
						player.abilities.append(event_name)
						# Create dialogue balloon
						var balloon : Node = Cutscene_Balloon.instantiate()
						get_tree().current_scene.add_child(balloon)
						balloon.start(dialogue_resource, dialogue_start)
						SignalManager.dialogue_start.emit()
						queue_free()
				EVENTS.OTHER:
					if event_name == "end_cutscene":
						Game.get_singleton().end_escape()
						SceneTransition.start_transition_to("cutscene", true, "res://UI/end_scene.tscn")
						
			
				
func _on_body_exited(body):
	if body.is_in_group(&"Player"):
		player = null
