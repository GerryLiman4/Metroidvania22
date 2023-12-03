extends Node

@onready var music_player = $AudioStreamPlayer

@onready var music_menu : AudioStreamOggVorbis = preload("res://Resources/Audio/Music/intro_cowboy.ogg")
@onready var music_town : AudioStreamOggVorbis = preload("res://Resources/Audio/Music/townsong_demo.ogg")

func _ready():
	#music_player.stream = main_menu_loop
	music_player.playing = true
	
	# figure out how to determine the scenes root nodes name
	#if get_tree().is_class("MainMenu"):
	#	music_player.playing = true
	
func handle_music_change():
	music_player.stop()
	match SceneTransition.curr_scene:
		SceneTransition.scenes.Menu:
			music_player.stream = music_menu
		SceneTransition.scenes.Game:
			music_player.stream = music_town
		SceneTransition.scenes.Cutscene:
			music_player.stream = music_menu
			
	music_player.playing = true
