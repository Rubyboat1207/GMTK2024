class_name GameManager extends Node2D

var machines = [
	preload('res://DoNothingMachine.tscn'),
	preload('res://ProduceNothingMachine.tscn')
]

var selected_machine = preload('res://DoNothingMachine.tscn')
var link_target: Building = null;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	grid_helper.manager = self
	
	grid_helper.place_machine(preload("res://OutputMachine.tscn"), Vector2(10, 4))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent):
	var grid_position = grid_helper.from_screen_space(get_viewport().get_mouse_position());
	var pos = grid_helper.snap_to_grid(get_viewport().get_mouse_position());
	
	if event is InputEventMouseMotion:		
		$SelectionDisplay.position = pos
	if Input.is_action_just_released("place"):
		
		if grid_helper.get_at_position(pos) == null:
			grid_helper.place_machine(selected_machine, grid_position)
	if Input.is_action_just_pressed("link"):
		var cur_target = grid_helper.get_at_position(grid_helper.from_screen_space(pos)) as Building
		if cur_target != null && link_target == null && cur_target.can_link:
			link_target = cur_target
		else:
			if !(link_target == null && cur_target == null):
				link_target.link(cur_target)
				link_target = null
	if Input.is_action_just_pressed("cycle_machines"):
		var idx = machines.find(selected_machine) + 1;
		if idx == machines.size():
			idx = 0;
		selected_machine = machines[idx]
	
