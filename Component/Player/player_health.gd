extends Health

class_name PlayerHealth

@export var is_immune : bool = false
@export var invincible_timer : Timer

func _enter_tree():
	area_entered.connect(get_contact)
	set_physics_process(false)

func get_contact(area : Area2D):
	if area.is_in_group("enemy") == true :
		# check if can be damaged
		if is_invincible == true :
			return
		
		var damage : int = area.get_contact_damage()
		print("get damage ", damage, " Health : ",health_point)
		get_damaged(damage,area.faction_id, area.global_position)
		is_invincible = true
		#set_physics_process(true)
		invincible_timer.start(invincible_timer.wait_time)

func _physics_process(delta):
	if is_invincible :
		return
	
	check_overlap_hitbox()

func check_overlap_hitbox() :
	var areas : Array[Area2D] = get_overlapping_areas()
	
	for area in areas :
		get_contact(area)

func _on_invincible_timer_timeout():
	#set_physics_process(true)
	check_overlap_hitbox()
	is_invincible = false
