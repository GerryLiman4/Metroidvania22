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
			SceneTransition.start_transition_to("game", true, "res://Component/TestLevels/level_base.tscn")
		"Dialogue Test":
			SceneTransition.start_transition_to("game", true, "res://Component/TestLevels/level_dialogue.tscn")
		"Tilemap Test":
			SceneTransition.start_transition_to("game", true, "res://level_test.tscn")
		"Reset Save":
			reset_save()
		"Toggle Music":
			AudioController.toggle_music()
			
func reset_save():
	var file_path = "user://save_data.sav"
	if FileAccess.file_exists(file_path):
		FileAccess.open("user://save_data.sav", FileAccess.WRITE).store_var({})
		toggle_message()
			
			
func toggle_message():
	%Message.visible = !%Message.visible
	if %Message.visible == true:
		$MessageTimer.start(5)	


func _on_message_timer_timeout():
	toggle_message()
