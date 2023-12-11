extends Node2D

@export var enemy_count : int

@export var max_bat_count: int
@export var max_spider_count: int
@export var max_enemy_count : int

@onready var bat = $Bat
@onready var spider = $Spider
@onready var random = $Random

@onready var timer = $Timer

var enemies = {
	"bat" : preload("res://Component/Enemy/enemy_bat.tscn"),
	"spider" : preload("res://Component/Enemy/enemy_hed.tscn"),
}

var bat_spawns
var spider_spawns
var random_spawns

var all_spawns : Array

func _ready():
	bat_spawns = bat.get_children()
	spider_spawns = spider.get_children()
	random_spawns = random.get_children()
	
	all_spawns = []
	
	all_spawns += bat_spawns
	all_spawns += spider_spawns
	all_spawns += random_spawns
	
	print(all_spawns)
	
	spawn_bat()
	#timer.start(1)
	
	
	
func spawn_bat():
	if bat_spawns.size() > 0:
		var first_spawn : Marker2D = bat_spawns[0]
		
		var name_to_remove = first_spawn.get("name")
		
		print(name_to_remove)
		
		all_spawns.erase(name_to_remove)
		
		var enemy_scene = enemies["bat"]
		var enemy_instance = enemy_scene.instantiate()
		
		add_child(enemy_instance)
		enemy_instance.position = first_spawn.position
		


func _on_timer_timeout():
	spawn_bat()
>>>>>>> Stashed changes
