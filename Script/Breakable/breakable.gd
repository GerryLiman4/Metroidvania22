extends Area2D

class_name Breakable

@export var faction_id : FactionId.Id
@export var health_point : int = 3

signal on_get_damaged(direction : Vector2)
signal dead

func get_damaged(damage : int, faction : FactionId.Id , direction : Vector2) :
	if faction == faction_id :
		return
	
	health_point -= damage
	on_get_damaged.emit(direction)
	
	if health_point <= 0 :
		dead.emit()
