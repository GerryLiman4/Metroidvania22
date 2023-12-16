extends Line2D
class_name PlayerTrail

var queue : Array
@export var max_length : int 

func add_to_queue(pos : Vector2):
	queue.push_front(pos)
	
	if queue.size() >= max_length :
		queue.pop_back()
	
	clear_points()
	
	for point in queue :
		add_point(point)
