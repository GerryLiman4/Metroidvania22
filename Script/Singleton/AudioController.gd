extends Node

@onready var music_player = $AudioStreamPlayer

@onready var music_menu : AudioStreamOggVorbis = preload("res://Resources/Audio/Music/intro_cowboy.ogg")
@onready var music_town : AudioStreamOggVorbis = preload("res://Resources/Audio/Music/townsong_demo.ogg")

@export var music_on : bool = false

func _ready():
	#music_player.stream = main_menu_loop
	music_player.playing = music_on
	
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
	
	if music_on:
		music_player.playing = true
	
func toggle_music():
	music_player.playing = !music_player.playing
	music_on = !music_on
