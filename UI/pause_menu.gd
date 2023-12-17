extends Control

class_name PauseMenu

var input_images : Dictionary = {
	"1" : preload("res://UI/inputmap.png"),
	"2" : preload("res://UI/inputmap2.png")
}

@onready var menu = %Menu
@onready var options = %Options
@onready var video = %Video
@onready var audio = %Audio
@onready var controls = %Controls

@onready var timer_container = $TimerContainer
@onready var game_over = %GameOver

var is_paused : bool = false

var player_ref : Player

var game_ref

signal pause_toggle(paused_state : bool)


# Called when the node enters the scene tree for the first time.
func _ready():
	player_ref = Player.get_singleton()
	game_ref = get_parent().get_parent()
	toggle()


func _unhandled_input(event):
	if Input.is_action_just_pressed("start") && (player_ref && !player_ref.event):
		hide_submenus()
		toggle()

# --------------- Helper Functions ------------------
	
func toggle():
	var first_option : Button = menu.get_child(0)
	first_option.grab_focus()
	visible = !visible
	if game_ref:
		update_timer_label(game_ref.game_timer)
	menu.show()
	get_tree().paused = visible
	emit_signal("pause_toggle", is_paused)

func update_timer_label(game_time):
	var total_seconds = int(game_time)
	var seconds = total_seconds % 60
	var minutes = total_seconds / 60
	
	%GameTimer.text = str(minutes) + " : " + str(seconds)
	
	
#Show first param, hide second
func show_and_hide(first, second):
	first.show()
	second.hide()
	var container = first.get_child(0)
	var inputs : VBoxContainer
	for child in container.get_children():
		if child.name == "Inputs":
			var first_option = child.get_child(0)
			first_option.grab_focus()
			return
			
	container.grab_focus()
		
		
func hide_submenus():
	options.hide()
	video.hide()
	audio.hide()
	controls.hide()
	game_over.hide()

func show_game_over():
	visible = !visible
	menu.hide()
	hide_submenus()
	game_over.show()
	game_over.get_child(1).grab_focus()
	get_tree().paused = visible
	emit_signal("pause_toggle", is_paused)
	if game_ref:
		update_timer_label(game_ref.game_timer)

# --------------- Menu Buttons ------------------

func _on_start_pressed():
	toggle()

func _on_options_pressed():
	show_and_hide(options, menu)

func _on_exit_pressed():
	toggle()
	Game.get_singleton().end_escape()
	get_tree().change_scene_to_file("res://UI/main.tscn")

# --------------- Option Buttons ------------------

func _on_video_pressed():
	show_and_hide(video, options)


func _on_audio_pressed():
	show_and_hide(audio, options)


func _on_back_from_options_pressed():
	show_and_hide(menu, options)


# --------------- Video Option Inputs ------------------


func _on_full_screen_toggled(button_pressed):
	if button_pressed == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_borderless_toggled(button_pressed):
	if button_pressed == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_v_sync_toggled(button_pressed):
	if button_pressed == true:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

func _on_back_from_video_pressed():
	show_and_hide(options, video)
	
# --------------- Audio Option Inputs ------------------

func _on_master_value_changed(value):
	volume(0, value)
	if (value == -10):
		AudioServer.set_bus_mute(0, true)
	else:
		AudioServer.set_bus_mute(0, false)

func _on_music_value_changed(value):
	volume(1, value)
	if (value == -10):
		AudioServer.set_bus_mute(1, true)
	else:
		AudioServer.set_bus_mute(1, false)

func _on_sfx_value_changed(value):
	volume(2, value)
	if (value == -10):
		AudioServer.set_bus_mute(2, true)
	else:
		AudioServer.set_bus_mute(2, false)
	
func _on_back_from_audio_pressed():
	show_and_hide(options, audio)
	
func volume(bus_index, value):
	AudioServer.set_bus_volume_db(bus_index, value)
	
func _on_toggle_music_toggled(toggled_on):
	AudioController.toggle_music()

func _on_reload_pressed():
	Game.get_singleton().reload_save()
	toggle()


func _on_controls_pressed():
	show_and_hide(controls, menu)
	if Player.get_singleton().abilities.has("crawl"):
		%ControlsImg.texture = input_images["2"]
	else:
		%ControlsImg.texture = input_images["1"]
	$Controls/BackFromControls.grab_focus()

func _on_back_from_controls_pressed():	
	show_and_hide(menu, controls)
	$Controls/BackFromControls.release_focus()
