extends StaticBody2D

@export var hitbox : Breakable

# Called when the node enters the scene tree for the first time.
func _ready():
	if Game.get_singleton().events.has("escape"):
		self.queue_free()
	
	hitbox.on_get_damaged.connect(on_get_damaged)
	hitbox.on_dead.connect(on_dead)

func on_get_damaged(direction : Vector2) :
	pass

func on_dead():
	# Ovveride A18
	var override1 := MetSys.get_cell_override_from_group(1)
	override1.set_assigned_scene("A18ES.tscn")
	override1.set_color(Color.BLUE)
	#Override AEntrance
	var override2 := MetSys.get_cell_override_from_group(2)
	override2.set_assigned_scene("AEntranceES.tscn")
	override2.set_color(Color.BLUE)
	
	override1.apply_to_group(1)
	override2.apply_to_group(2)
	
	Game.get_singleton().events.append("escape")
	
	self.queue_free()
