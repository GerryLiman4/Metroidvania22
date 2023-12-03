extends Control
class_name MainMenu

func _on_menu_activated(element) -> void:
	prints("element: ", element.text)
	
	match (element.text):
		"Intro":
			SceneTransition.start_transition_to("cutscene", false, "res://UI/intro_scene.tscn")
		"Game":
			SceneTransition.start_transition_to("game", true, "res://Game.tscn")
		"Level Test":
			SceneTransition.start_transition_to("game", true, "res://Component/Level/level_base.tscn")
		"TileMap Test":
			SceneTransition.start_transition_to("game", true, "res://Component/Level/level_base.tscn")
