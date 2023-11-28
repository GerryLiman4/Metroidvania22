extends Health

class_name PlayerHealth

func _enter_tree():
	area_entered.connect(get_contact)

func get_contact(area : Area2D):
	if area.is_in_group("enemy") == true :
		
		var damage : int = area.get_contact_damage()
		print("get damage ", damage)
		get_damaged(damage,area.faction_id, area.global_position)
