extends Node

@export var music_on : bool = false

@onready var music_player = $Music
@onready var sfx_player = $SFX
@onready var ambient_player = $Ambient

@onready var music_menu : AudioStreamOggVorbis = preload("res://Resources/Audio/Music/intro_cowboy.ogg")
@onready var music_town : AudioStreamOggVorbis = preload("res://Resources/Audio/Music/town_song.ogg")
@onready var music_abyss1 : AudioStreamOggVorbis = preload("res://Resources/Audio/Music/abyss_demo.ogg")
@onready var music_abyss2 : AudioStreamOggVorbis = preload("res://Resources/Audio/Music/abyss_2faster.ogg")

@onready var cave_collapse = preload("res://Resources/Audio/SFX/Environment/cave_collapse.wav")

var audioScenes := {
	"collect0" : preload("res://Resources/Audio/SFX/shard_collect-001.ogg"),
	"collect1" : preload("res://Resources/Audio/SFX/shard_collect-002.ogg"),
	"collect2" : preload("res://Resources/Audio/SFX/shard_collect-003.ogg"),
	"collect3" : preload("res://Resources/Audio/SFX/shard_collect-004.ogg"),
	"collect4" : preload("res://Resources/Audio/SFX/shard_collect-005.ogg"),
	"explosion0" : preload("res://Resources/Audio/SFX/Environment/explosion-001.ogg"),
	"explosion1" : preload("res://Resources/Audio/SFX/Environment/explosion-002.ogg"),
	"explosion2" : preload("res://Resources/Audio/SFX/Environment/explosion-003.ogg"),
	"explosion3" : preload("res://Resources/Audio/SFX/Environment/explosion-004.ogg"),
	"savepoint" : preload("res://Resources/Audio/SFX/Environment/Save_Game.ogg"),
	"ability": preload("res://Resources/Audio/SFX/Environment/Acquire_new_skill.ogg"),
	"boxbreak" : preload("res://Resources/Audio/SFX/Environment/Box_Break.ogg")
}

var escape_active : bool = false


	# figure out how to determine the scenes root nodes name
	#if get_tree().is_class("MainMenu"):
	#	music_player.playing = true
	
func play_menu_music():
	music_player.stream = music_menu
	if music_on:
		music_player.playing = true
	
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
	
func change_music(music_name : String):
	if !escape_active:
		music_name = music_name.to_lower()
		match (music_name):
				"menu":
					music_player.stream = music_menu
				"town":
					music_player.stream = music_town
				"abyss":
					music_player.stream = music_abyss1
				"abyss2":
					music_player.stream = music_abyss2
					
		if music_on:
			music_player.playing = true

func play_random_sfx():
	#rewrite to work with dictonary
	pass

func play_collectable_sfx():
	var collectSFXKeys := ["collect0", "collect1", "collect2", "collect3", "collect4"]
	var randomKey = collectSFXKeys[randi() % collectSFXKeys.size() - 1]
	
	if randomKey in audioScenes && sfx_player.playing == false:
		sfx_player.stream = audioScenes[randomKey]
		sfx_player.pitch_scale = randf_range(0.9, 1.1)
		sfx_player.call_deferred("play")
		await sfx_player.finished
	else:
		print(randomKey + " not found in audioScenes, or SFX already playing")
		
			
func play_sfx(sfx_name : String):
	var sfx_key = audioScenes[sfx_name]
	
	if sfx_name in audioScenes:
		var sfx = audioScenes[sfx_name]
		sfx_player.stream = sfx_key
		sfx_player.pitch_scale = randf_range(0.9, 1.1)
		sfx_player.call_deferred("play")
		await sfx_player.finished
		
func play_explosion_sfx():
	var explosionSFXKeys := ["explosion0", "explosion1", "explosion2", "explosion3"]
	var randomKey = explosionSFXKeys[randi() % explosionSFXKeys.size() - 1]
	
	if randomKey in audioScenes && sfx_player.playing == false:
		sfx_player.stream = audioScenes[randomKey]
		sfx_player.pitch_scale = randf_range(0.9, 1.1)
		sfx_player.call_deferred("play")
		await sfx_player.finished
	else:
		print(randomKey + " not found in audioScenes, or SFX already playing")

func start_escape():
	escape_active = true
	music_player.stream = music_abyss2
	ambient_player.stream = cave_collapse
	
	music_player.play()
	ambient_player.playing = true
	ambient_player.play()
	
func end_escape():
	escape_active = false

	music_player.stop()
	ambient_player.stop()
