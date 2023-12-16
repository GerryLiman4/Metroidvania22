extends Area2D

@export var contact_damage : int = 1
@export var faction_id : FactionId.Id = FactionId.Id.NEUTRAL

func get_contact_damage() -> int :
	return contact_damage
