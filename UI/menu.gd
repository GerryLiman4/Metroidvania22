extends VBoxContainer
class_name Menu 

# Signal for when menu element is activated
signal activated(element : Control)


@onready var selector = %Selector


func _ready():
	get_viewport().gui_focus_changed.connect(_on_focus_changed)
	await setup_focus()
	var first_option = $Play
	first_option.grab_focus()
	update_selection()
	selector.global_position = Vector2(global_position.x - 50, $Play.global_position.y + $Play.size.y * 0.5)
	selector.play("default")


func _unhandled_input(event):
	if not visible : return #Check if menu is visible/active
	
	get_viewport().set_input_as_handled() #Override all other inputs in the viewport
	
	var element = get_focused_element()
	if is_instance_valid(element) and event.is_action_pressed("any"):
		activated.emit(element)
	

func get_elements() -> Array[Control]:
	var items : Array[Control] = []
	for child in get_children():
		if not child is Control: continue #Filter non-control elements
		if "Heading" in child.name: continue #Filter Heading elements
		if "Divider" in child.name: continue #Filter Divider elements
		items.append(child)
		
	return items


func setup_focus():
	var elements = get_elements()
	for i in elements.size():
		var element : Control = elements[i]
		
		element.focus_mode = Control.FOCUS_ALL
		#Vertical menu so set left & right neighbors to self
		element.focus_neighbor_left = element.get_path()
		element.focus_neighbor_right = element.get_path()
		#If first element in the list
		if i == 0: 
			element.focus_neighbor_top = element.get_path() #Set foxus neighbor top & previous to self
			element.focus_previous = element.get_path()
			element.grab_focus() #Set focus to self
		else: #Otherwise
			element.focus_neighbor_top = elements[i - 1].get_path() #Set foxus neighbor top & previous to previous index
			element.focus_previous = elements[i - 1].get_path()	
		# If last element in the list
		if i == elements.size() - 1: 
			element.focus_neighbor_bottom = element.get_path() #Set focus neighbor bottom & next to self
			element.focus_next = element.get_path()
		else: #Otherwise
			element.focus_neighbor_bottom = elements[i + 1].get_path() #Set foxus neighbor top & previous to next index
			element.focus_next = elements[i + 1].get_path()		
		# TODO: Implement Wrapping


func get_focused_element() -> Control:
	# Get currenly focused element & return if its a child of this menu
	var element = get_viewport().gui_get_focus_owner()
	return element if element in get_children() else null


func update_selection():
	var element = get_focused_element()
	
	if is_instance_valid(element) and is_instance_valid(selector) and visible:
		selector.global_position = Vector2(global_position.x - 50, element.global_position.y + element.size.y * 0.5)


func _on_focus_changed(element : Control):
	# Determine if newly focused element is part of this menu
	if not element : return
	if not element in get_children() : return
	
	update_selection()
