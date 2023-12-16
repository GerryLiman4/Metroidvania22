extends StaticBody2D

const Cutscene_Balloon = preload("res://Dialogue/Dialogue/cutscene_balloon.tscn")

@export var hitbox : Breakable
@export var type : TYPE

enum TYPE{NORMAL, ESCAPE}

# Called when the node enters the scene tree for the first time.
func _ready():
	hitbox.on_get_damaged.connect(on_get_damaged)
	hitbox.on_dead.connect(on_dead)
	
	MetSys.register_storable_object(self, queue_free)

func on_get_damaged(direction : Vector2) :
	pass

func on_dead():
	if type == TYPE.ESCAPE:
		var game_ref = Game.get_singleton()
		game_ref.events.append("escape")
		game_ref.start_escape()
		
		var balloon : Node = Cutscene_Balloon.instantiate()
		get_tree().current_scene.add_child(balloon)
		balloon.start(load("res://Dialogue/Dialogue/event.dialogue"), "escape_start")
		SignalManager.dialogue_start.emit()
	
	AudioController.play_sfx("boxbreak")
	MetSys.store_object(self)
	self.queue_free()
