extends Node

#region player

signal player_dash(cooldown_time : float)
signal dialogue_start()
signal dialogue_end()

signal player_damaged(life_left : int)
signal player_dead()
signal player_health_updated(life_point : int)
#endregion
