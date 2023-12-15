extends Node2D

@onready var input_delay_timer = $InputDelayTimer

@onready var animation_player : AnimationPlayer = $AnimationPlayer

var input_ready : bool = false


func _unhandled_input(_event: InputEvent) -> void:
	if input_ready == true:
		if(Input.is_action_just_pressed("any")):
			_proceed_to_game()
			input_ready = false
		#elif(Input.is_action_just_pressed("escape")):
		#	SceneTransition.start_transition_to("menu", true, "res://Menu.tscn")
		

func _ready():
	#Start input delay timer
	input_delay_timer.start(3)
	#Play scene_1
	animation_player.play("scene_1")
	
	$Scene2/Actionable.action()

	for child in get_children():
		if child.name == "CutsceneBalloon":
			child.connect("dialog_ended", _proceed_to_game)
			return
			
func play_scene_2():
	$Scene1.hide()
	animation_player.play("scene_2")
	
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
	
func _proceed_to_game():
	SceneTransition.start_transition_to("game", false, "res://Game.tscn")

func _on_input_delay_timer_timeout():
	input_ready = true
