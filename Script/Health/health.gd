extends Area2D

class_name Health

@export var faction_id : FactionId.Id
@export var health_point : int = 3

@export var is_invincible : bool = false

signal on_get_damaged(direction : Vector2)
signal on_dead

func get_damaged(damage : int, faction : FactionId.Id , direction : Vector2) :
	if faction == faction_id or is_invincible == true :
		return
	
	health_point -= damage
	on_get_damaged.emit(direction)
	
	if health_point <= 0 :
		on_dead.emit()

