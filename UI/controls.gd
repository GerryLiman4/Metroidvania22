extends Control


func _ready():
	$Button.grab_focus()
	
func _unhandled_input(event):
	if Input.is_action_just_pressed("any"):
		SceneTransition.start_transition_to("menu", false, "res://UI/main.tscn")
