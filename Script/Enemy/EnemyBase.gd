extends CharacterBody2D

class_name BaseEnemy

@export var animated_sprite : AnimatedSprite2D 
@export var health : Health

@export var enemy_state : StateChart

enum FACING{RIGHT,LEFT}
@export var face_direction : FACING

func _on_idle_state_entered():
	pass # Replace with function body.

func _on_idle_state_exited():
	pass # Replace with function body.

func _on_idle_state_physics_processing(delta):
	pass # Replace with function body.


func _on_chasing_state_entered():
	pass # Replace with function body.

func _on_chasing_state_exited():
	pass # Replace with function body.

func _on_chasing_state_physics_processing(delta):
	pass # Replace with function body.


func _on_patroling_state_entered():
	pass # Replace with function body.

func _on_patroling_state_exited():
	pass # Replace with function body.

func _on_patroling_state_physics_processing(delta):
	pass # Replace with function body.
