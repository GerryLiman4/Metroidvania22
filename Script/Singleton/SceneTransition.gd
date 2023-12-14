extends CanvasLayer

var curr_scene = scenes.Menu

enum scenes {
	Menu,
	Cutscene,
	Game,
}

var new_scene : String

@onready var animation_player = $AnimationPlayer

var player_data : Dictionary

func start_transition_to(scene_name : String, change_music : bool, path_to_scene : String) -> void:
	match scene_name:
		"menu":
			curr_scene = scenes.Menu
		"game":
			curr_scene = scenes.Game
		"cutscene":
			curr_scene = scenes.Cutscene
	
	if change_music == true:
		AudioController.handle_music_change()
	
	new_scene = path_to_scene
	animation_player.play("change_scene_to_file")
	
func change_scene_to_file() -> void:
	# Make sure path is correct with assert
	var __ = get_tree().change_scene_to_file(new_scene) == OK
	assert(__)
	
func transition() -> void:
	animation_player.play("transition")

