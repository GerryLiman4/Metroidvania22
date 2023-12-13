extends Node2D

@export var enemy_max : int

@export var bat_max: int
@export var spider_max: int
@export var gopher_max: int

@onready var bat = $Bat
@onready var spider = $Spider
@onready var gopher = $Gopher

@onready var timer = $Timer

var enemies_spawned : int = 0

var enemy_limit_reached : bool = false

@onready var enemies = {
	"bat" : {
		#"scene": preload("res://Component/Enemy/enemy_bat.tscn"),
		"spawned": 0,
		"max_spawns": bat_max,
		"spawn_positions": []
	},
	"spider" : {
		#"scene": preload("res://Component/Enemy/enemy_hed.gd"),
		"spawned": 0,
		"max_spawns": spider_max,
		"spawn_positions": []
	},
	"gopher" : {
		#"scene": preload("res://Component/Enemy/enemy_gunner.tscn"),
		"spawned": 0,
		"max_spawns": gopher_max,
		"spawn_positions": []
	}
}

var map

var bat_spawns : Array
var spider_spawns : Array
var gopher_spawns : Array

func _ready():
	
	fill_spawn_positions(bat, "bat")
	fill_spawn_positions(spider, "spider")
	fill_spawn_positions(gopher, "gopher")
	
	if enemies_spawned >= enemy_max:
		enemy_limit_reached = true
	#Spawn random enemy if
	timer.start(.2)
	
func fill_spawn_positions(spawn_category : Node, dict_category: String) -> void:
	var spawn_points = spawn_category.get_children()
	
	for spawn in spawn_points:
		if spawn is Marker2D:
			enemies[dict_category]["spawn_positions"].append(spawn.position)

func spawn() -> void:
	while !enemy_limit_reached:
		var type = get_random_type()
		
		if !type:
			return
		
		var enemy_data = enemies[type]
		
		if enemy_data["spawned"] < enemy_data["max_spawns"] && enemy_data["spawn_positions"].size() > 0:
			enemy_data["spawn_positions"].shuffle()
			var spawn_data = enemy_data["spawn_positions"].pop_back()
			print ("Spawning ", type, " at position: ", spawn_data)
			var enemy_instance = Game.get_singleton().get_enemy(type).instantiate()
			get_parent().add_child.call_deferred(enemy_instance)
			enemy_instance.position = spawn_data
			enemy_instance.scale = Vector2(0.5, 0.5)
			increment_spawned_count(type)
			increment_total_spawned_count()
			

func increment_spawned_count(type : String) -> void:
	enemies[type]["spawned"] += 1 
	
func increment_total_spawned_count() -> void:
	enemies_spawned += 1
	if enemies_spawned >= enemy_max:
		#Handle limit exceeded
		enemy_limit_reached = true


func get_random_type() -> String:
	var availabe_categories = []
	
	for enemy_name in enemies.keys():
		var enemy_data = enemies[enemy_name]
		if enemy_data["spawn_positions"].size() > 0 and enemy_data["spawned"] < enemy_data["max_spawns"]:
			availabe_categories.append(enemy_name)

	if availabe_categories.size() > 0:
		return availabe_categories[randi() % availabe_categories.size() - 1]
	else:
		return ""

func _on_timer_timeout():
	spawn()
