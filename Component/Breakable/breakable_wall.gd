extends StaticBody2D

@export var hitbox : Breakable
@export var type : TYPE

enum TYPE{NORMAL, ESCAPE}

# Called when the node enters the scene tree for the first time.
func _ready():
	if type == TYPE.ESCAPE && Game.get_singleton().events.has("escape"):
		self.queue_free()
	
	hitbox.on_get_damaged.connect(on_get_damaged)
	hitbox.on_dead.connect(on_dead)

func on_get_damaged(direction : Vector2) :
	pass

func on_dead():
	if type == TYPE.ESCAPE:
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
		# Append "escape" event
		Game.get_singleton().events.append("escape")
	
	self.queue_free()
