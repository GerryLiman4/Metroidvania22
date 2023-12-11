extends Area2D

# Custom Dialgoue Balloon with portriats
const Portrait_Balloon = preload("res://Dialogue/Dialogue/portrait_balloon.tscn")
const Cutscene_Balloon = preload("res://Dialogue/Dialogue/cutscene_balloon.tscn")

@export var automatic : bool = false
@export var event : String

# Dialogue file and start positions
@export var dialogue_resource : DialogueResource
@export var dialogue_start : String = "start"

var player : CharacterBody2D

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
		if (automatic && event):
			if !Game.get_singleton().events.has(event):
				Game.get_singleton().events.append(event)
				# Create dialogue balloon
				var balloon : Node = Cutscene_Balloon.instantiate()
				get_tree().current_scene.add_child(balloon)
				balloon.start(dialogue_resource, dialogue_start)
				SignalManager.dialogue_start.emit()
				
func _on_body_exited(body):
	if body.is_in_group(&"Player"):
		player = null
