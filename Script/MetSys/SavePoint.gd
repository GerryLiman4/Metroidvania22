# A save point object. Colliding with it saves the game.
extends Area2D

@onready var start_time := Time.get_ticks_msec()

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var timer = $Timer
@onready var label = $Label

var message_display : bool

func _ready() -> void:
	body_entered.connect(on_body_entered)
	animated_sprite_2d.play("default")
	label.hide()
	message_display = false

# Player enter save point. Note that in a legit code this should check whether body is really a player.
func on_body_entered(body: Node2D) -> void:
	if Time.get_ticks_msec() - start_time < 1000:
		return # Small hack to prevent saving at the game start.
	# Get the game-specific save data Dictionary.
	var save_data := Game.get_singleton().get_save_data()
	# Merge it with the Dicionary from MetSys.
	save_data.merge(MetSys.get_save_data())
	
	print(save_data)
	print(MetSys.get_save_data())
	
	if FileAccess.file_exists("user://save_data.sav"):
		# Save the file.
		FileAccess.open("user://save_data.sav", FileAccess.WRITE).store_var(save_data)
	# Starting coords for the delta vector feature.
	Game.get_singleton().reset_map_starting_coords()
	
	AudioController.play_sfx("savepoint")
	
	if !message_display:
		message_display = true
		label.show()
		timer.start()


func _on_timer_timeout():
	message_display = false
	label.hide()
