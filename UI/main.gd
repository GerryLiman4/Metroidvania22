extends Control
class_name MainMenu

func _on_menu_activated(element) -> void:
	prints("element: ", element.text)
	
	match (element.text):
		"Play":
			SceneTransition.start_transition_to("cutscene", false, "res://UI/intro_scene.tscn")
		"TileMap Test":
			SceneTransition.start_transition_to("game", true, "res://level_test.tscn")
		"LevelBase Test":
			SceneTransition.start_transition_to("game", true, "res://Component/Level/level_base.tscn")
