extends Area2D

# Custom Dialgoue Balloon with portriats
const Balloon = preload("res://Dialogue/Dialogue/portrait_balloon.tscn")

# Dialogue file and start positions
@export var dialogue_resource : DialogueResource
@export var dialogue_start : String = "start"

func action() -> void:
	var balloon : Node = Balloon.instantiate()
	get_tree().current_scene.add_child(balloon)
	balloon.start(dialogue_resource, dialogue_start)
	#DialogueManager.show_dialogue_balloon(dialogue_resourse, dialogue_start)
	#DialogueManager.show_example_dialogue_balloon(dialogue_resource, dialogue_start)
