extends Control


func _on_menu_activated(element) -> void:
	prints("element: ", element.text)
	
	match (element.text):
		"1st element":
			SceneTransition.start_transition_to("cutscene", false, "res://UI/intro_scene.tscn")
		
			
