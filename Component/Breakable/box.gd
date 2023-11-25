extends RigidBody2D

@export var hitbox : Breakable

# Called when the node enters the scene tree for the first time.
func _ready():
	hitbox.on_get_damaged.connect(on_get_damaged)
	hitbox.dead.connect(on_dead)

func on_get_damaged(direction : Vector2) :
	pass

func on_dead() :
	self.queue_free()
