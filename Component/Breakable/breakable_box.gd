extends StaticBody2D

@export var hitbox : Breakable

var is_destroyed : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	hitbox.on_get_damaged.connect(on_get_damaged)
	hitbox.on_dead.connect(on_dead)
	MetSys.register_storable_object(self, queue_free)

func on_get_damaged(direction : Vector2) :
	pass

func on_dead() :
	MetSys.store_object(self)
	self.queue_free()

