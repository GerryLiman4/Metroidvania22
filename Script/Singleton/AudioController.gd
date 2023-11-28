extends Node

@onready var music_player = $AudioStreamPlayer

@onready var main_menu_loop : AudioStreamOggVorbis = preload("res://UI/cowboy.ogg")


func _ready():
	#music_player.stream = main_menu_loop
	music_player.playing = false
	
func handle_music_change():
	music_player.stop()
	match SceneTransition.curr_scene:
		SceneTransition.scenes.Menu:
			music_player.stream = main_menu_loop
		SceneTransition.scenes.Game:
			music_player.stream = null
		SceneTransition.scenes.Cutscene:
			music_player.stream = main_menu_loop
			
	music_player.playing = true
