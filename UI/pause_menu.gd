extends Control

@onready var menu = %Menu
@onready var options = %Options
@onready var video = %Video
@onready var audio = %Audio

var is_paused : bool = false

signal pause_toggle(paused_state : bool)

# Called when the node enters the scene tree for the first time.
func _ready():
	toggle()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("start"):
		hide_submenus()
		toggle()
		
# --------------- Helper Functions ------------------
	
func toggle():
	var first_option : Button = menu.get_child(0)
	first_option.grab_focus()
	visible = !visible
	menu.show()
	get_tree().paused = visible
	emit_signal("pause_toggle", is_paused)
	
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

# --------------- Menu Buttons ------------------

func _on_start_pressed():
	toggle()

func _on_options_pressed():
	show_and_hide(options, menu)

func _on_exit_pressed():
	toggle()
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
