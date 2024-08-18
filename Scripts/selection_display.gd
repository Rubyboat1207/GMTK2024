class_name SelectionDisplay extends Node2D

var machine_display: Building;

func on_machine_cycled(selected_machine: PackedScene):
	if get_children().size() > 0:
		get_child(0).queue_free()
	machine_display = selected_machine.instantiate()
	
	machine_display.display = true
	
	#(machine_display.get_node('Sprite2D') as Sprite2D).self_modulate.a = 0.25
	
	machine_display.set_alpha(0.25)
	
	add_child(machine_display)
	
	set_child_visibility()

func set_child_visibility():
	var grid_position = grid_helper.get_current_grid_selection();
		
	if !grid_helper.is_placable(grid_position):
		machine_display.set_hidden()
	else:
		machine_display.set_shown()

func _input(event):
	if event is InputEventMouseMotion:
		set_child_visibility()
