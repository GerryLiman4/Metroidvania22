extends Control

#region dash
@onready var dash_skill = $MarginContainer/Skills/SkillsPanel/DashSkill
@onready var dash_timer = $MarginContainer/Skills/SkillsPanel/DashSkill/DashTimer

var dash_cooling_down : bool = false
#endregion

func _ready():
	# region connect all the signal
	SignalManager.player_dash.connect(on_player_dash)

func _process(delta):
	# calculate the dash hud
	if dash_cooling_down == true :
		dash_skill.set_value_no_signal((dash_timer.wait_time - dash_timer.time_left) / dash_timer.wait_time * 100.0)

#region dash
func on_player_dash(cooldown_time : float) :
	dash_skill.set_value_no_signal(0.0)
	dash_timer.wait_time = cooldown_time
	dash_timer.start(dash_timer.wait_time)
	dash_cooling_down = true

func _on_dash_timer_timeout():
	dash_skill.set_value_no_signal(100.0)
	dash_cooling_down = false
#endregion
