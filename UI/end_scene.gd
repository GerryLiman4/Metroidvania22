extends Node2D

@onready var input_delay_timer = $InputDelayTimer

@onready var animation_player : AnimationPlayer = $AnimationPlayer

var input_ready : bool = false

var player_data

func _unhandled_input(_event: InputEvent) -> void:
	if input_ready == true:
		if(Input.is_action_just_pressed("any")):
			SceneTransition.player_data.clear()
			_proceed_to_menu()
			input_ready = false
		#elif(Input.is_action_just_pressed("escape")):
		#	SceneTransition.start_transition_to("menu", true, "res://Menu.tscn")
		

func _ready():
	#Start input delay timer
	input_delay_timer.start(3)
	
	# Set stats
	player_data = SceneTransition.player_data
	if player_data.has("collectible_count"):
		$Scene3/Stats/Collectables.text = "You found " + player_data["collectable_count"] + " / 20 Collectables"
	else:
		$Scene3/Stats/Collectables.text = "Player data not found"
	
	#Play scene_1
	animation_player.play("scene_1")
	$Scene1/Actionable.action()
	
	for child in get_children():
		if child.name == "CutsceneBalloon":
			child.connect("dialog_ended", play_scene_2)
			return
			
			
func play_scene_2():	
	animation_player.play("scene_2")
	
	#stop audio and animation from scene_1
	'
	if audio_stream.playing:
		audio_stream.stop()
	animated_bg_sprite.stop()
	animated_ship_sprite.stop()
	'
	'''
	#Start scene_2 audio
	audio_stream.set_stream(crashing_audio)
	audio_stream.play()
	'''
	
	
func play_scene_3():
	#Credits
	animation_player.play("scene_3")


func play_scene_4():
	# Stats
	animation_player.play("scene_3")
	
func _proceed_to_menu():
	SceneTransition.start_transition_to("menu", true, "res://UI/main.tscn")

func _on_input_delay_timer_timeout():
	input_ready = true
