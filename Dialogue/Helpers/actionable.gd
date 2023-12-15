extends Area2D

# Custom Dialgoue Balloon with portriats
#const Portrait_Balloon = preload("res://Dialogue/Dialogue/portrait_balloon.tscn")
const Cutscene_Balloon = preload("res://Dialogue/Dialogue/cutscene_balloon.tscn")

# Dialogue file and start positions
@export var dialogue_resource : DialogueResource
@export var dialogue_start : String = "start"

var player : CharacterBody2D

func action() -> void:
	var balloon : Node = Cutscene_Balloon.instantiate()
	get_tree().current_scene.add_child(balloon)
	balloon.start(dialogue_resource, dialogue_start)
	SignalManager.dialogue_start.emit()
	'''
	var balloon : Node = Portrait_Balloon.instantiate()
	get_tree().current_scene.add_child(balloon)
	balloon.start(dialogue_resource, dialogue_start)
	'''
	
