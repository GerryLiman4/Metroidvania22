# This is the main script of the game. It manages the current map and some other stuff.
extends Node2D
class_name Game

# The game starts in this map. Note that it's scene name only, just like MetSys refers to rooms.
@export var starting_map: String
# Player node, bruh.
@onready var player: CharacterBody2D =  $Player
@onready var pause_menu = $UI/PauseMenu

@onready var enemy_scenes : Dictionary = {
	"bat" : preload("res://Component/Enemy/enemy_bat.tscn"),
	"spider" : preload("res://Component/Enemy/enemy_hed.tscn"),
	"gopher": preload("res://Component/Enemy/enemy_gopher.tscn"),
	"slime": preload("res://Component/Enemy/enemy_gunner.tscn")
}

@onready var escape_timer = $EscapeTimer

var escape_health : int = 20

# The current map scene instance.
var map: Node2D

# Number of collected collectibles. Setting it also updates the counter.
var collectibles: int:
	set(count):
		collectibles = count
		%CollectibleCount.text = "%d/20" % count

# The coordinates of generated rooms. MetSys does not keep this list, so it needs to be done manually.
var generated_rooms: Array[Vector3i]
# The typical array of game events. It's supplementary to the storable objects.
var events: Array[String]


func _ready() -> void:
	randomize()
	SignalManager.player_dead.connect(on_player_dead)
	# Make sure MetSys is in initial state.
	# Does not matter in this project, but normally this ensures that the game works correctly when you exit to menu and start again.
	MetSys.reset_state()
	
	if FileAccess.file_exists("user://save_data.sav"):
		load_save()
	else:
		reset_save()
	
	go_to_starting_map()
	
	# Connect the room_changed signal to handle room transitions.
	MetSys.room_changed.connect(on_room_changed, CONNECT_DEFERRED)
	# Reset position tracking (feature specific to this project).
	reset_map_starting_coords.call_deferred()
	# A trick for static object reference (before static vars were a thing).
	get_script().set_meta(&"singleton", self)

func go_to_starting_map():
	# Go to the starting point.
	goto_map(MetSys.get_full_room_path(starting_map))
	# Find the save point and teleport the player to it, to start at the save point.
	travel_to_point("SavePoint")
	
func load_save():
	# If save data exists, load it.
	var save_data: Dictionary = FileAccess.open("user://save_data.sav", FileAccess.READ).get_var()
	if !save_data.is_empty():
		# Send the data to MetSys (it has extra keys, but it doesn't matter).
		MetSys.set_save_data(save_data)
		# Load various data stored in the dictionary.
		collectibles = save_data.collectible_count
		generated_rooms.assign(save_data.generated_rooms)
		events.assign(save_data.events)
		starting_map = save_data.current_room
		player.abilities.assign(save_data.abilities)
	else:
		reset_save()
		
func reload_save():
	load_save()
	player.reset_health()
	go_to_starting_map()
	
func reset_save():
	MetSys.set_save_data()
	var file_path = "user://save_data.sav"
	FileAccess.open("user://save_data.sav", FileAccess.WRITE).store_var({})
	var initial_save_data := get_init_save_data()
	# Merge it with the Dicionary from MetSys.
	initial_save_data.merge(MetSys.get_save_data())
	
	if FileAccess.file_exists("user://save_data.sav"):
		# Save the file.
		FileAccess.open("user://save_data.sav", FileAccess.WRITE).store_var(initial_save_data)


# Loads a room scene and removes the current one if exists.
func goto_map(map_path: String, fast_travel : bool = false):
	var prev_map: Node2D
	var prev_map_groups : Array
	if map:
		# If some map is already loaded (which is true anytime other than the beginning), keep a reference to the old instance and queue free it.
		prev_map = MetSys.get_current_room_instance()
		prev_map_groups = map.get_groups()
		map.queue_free()
		map = null
	
	# Load the new map scene.
	map = load(map_path).instantiate()
	add_child(map)
	# Adjust the camera.
	MetSys.get_current_room_instance().adjust_camera_limits($Player/Camera2D)
	# Set the current layer to the room's layer.
	MetSys.current_layer = MetSys.get_current_room_instance().get_layer()
	
	# If previous map has existed, teleport the player based on map position difference.
	if fast_travel == true:
		travel_to_point("FastTravel")
	elif prev_map:
		player.position -= MetSys.get_current_room_instance().get_room_position_offset(prev_map)
		player.on_enter()
		
	change_music(map, prev_map_groups)
	

func change_music(map, prev_map_groups):
	var map_groups : Array = map.get_groups()
	
	if map_groups.is_empty():
		return

	if prev_map_groups.is_empty():
		AudioController.change_music(map_groups[0])
		return
	
	if map_groups.size() > 0 && map_groups[0] != prev_map_groups[0]:
		AudioController.change_music(map_groups[0])

func travel_to_save_point():
	# Find the save point and teleport the player to it, to start at the save point.
	var start := map.get_node_or_null(^"SavePoint")
	if start:
		player.position = start.position
		
func travel_to_point(node_name):
	# Find the save point and teleport the player to it, to start at the save point.
	var start := map.get_node_or_null(node_name)
	if start:
		player.position = start.position
		#player.position = start.position - Vector2(0, 25)

func _physics_process(delta: float) -> void:
	# Notify MetSys about the player's current position.
	MetSys.set_player_position(player.position)

func on_room_changed(target_map: String):
	# Randomly generated rooms use absolute paths, so this needs to be checked.
	if target_map.is_absolute_path():
		goto_map(target_map)
	else:
		# If target_map is only the scene name (default behavior of assigned scenes), get the full path.
		goto_map(MetSys.get_full_room_path(target_map))

# Returns this node from anywhere.
static func get_singleton() -> Game:
	return (Game as Script).get_meta(&"singleton") as Game

# Project-specific save data Dictionary. It's merged with the MetSys one.
func get_save_data() -> Dictionary:
	return {
		"collectible_count": collectibles,
		"generated_rooms": generated_rooms,
		"events": events,
		"current_room": MetSys.get_current_room_name(),
		"abilities": player.abilities
	}

func get_init_save_data() -> Dictionary:
	return {
		"collectible_count": collectibles,
		"generated_rooms": generated_rooms,
		"events": events,
		"current_room": "StartingPoint.tscn",
		"abilities": player.abilities
	}


func get_enemy(type : String) -> PackedScene:
	if enemy_scenes.has(type):
		return enemy_scenes[type]
	else:
		return preload("res://Component/Enemy/enemy_hed.tscn")
	

func reset_map_starting_coords():
	$UI/MapWindow.reset_starting_coords()
	
	
func start_escape():
	if events.has("escape"):
		AudioController.start_escape()
		escape_timer.start(10)
		
		# Ovveride A18
		var override1 := MetSys.get_cell_override_from_group(1)
		override1.set_assigned_scene("A18ES.tscn")
		override1.set_color(Color.RED)
		#Override AEntrance
		var override2 := MetSys.get_cell_override_from_group(2)
		override2.set_assigned_scene("AEntranceES.tscn")
		override2.set_color(Color.BLUE)
		#Override AStartingpoint
		var override3 := MetSys.get_cell_override_from_group(3)
		override3.set_assigned_scene("StartingPointES.tscn")
		override3.set_color(Color.BLUE)
		#Apply overrides
		override1.apply_to_group(1)
		override2.apply_to_group(2)
		override3.apply_to_group(3)


func end_escape():
	AudioController.end_escape()
	escape_timer.stop()
	# Undo all previous overrides
	# Ovveride A18
	var override1 := MetSys.get_cell_override_from_group(1)
	override1.set_assigned_scene("res://Component/Maps/A18.tscn")
	override1.set_color(Color.ORANGE)
	#Override AEntrance
	var override2 := MetSys.get_cell_override_from_group(2)
	override2.set_assigned_scene("res://Component/Maps/AEntrance.tscn")
	override2.set_color(Color.ORANGE)
	#Override AStartingpoint
	var override3 := MetSys.get_cell_override_from_group(3)
	override3.set_assigned_scene("res://Component/Maps/StartingPoint.tscn")
	override3.set_color(Color.GREEN)
	#Apply overrides
	override1.apply_to_group(1)
	override2.apply_to_group(2)
	override3.apply_to_group(3)
	escape_health = 20

func _on_escape_timer_timeout():
	escape_health -= 1
	if !escape_health <= 0:
		AudioController.play_explosion_sfx()
		player.camera_shake()
		escape_timer.start(10)
		print("Cave collapsing - " + "Cave health : " + str(escape_health))
	else:
		#Game over
		on_player_dead()
		end_escape()
		print("Cave collapsed..")
		
func on_player_dead():
	pause_menu.show_game_over()
