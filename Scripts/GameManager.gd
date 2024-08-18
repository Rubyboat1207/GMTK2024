class_name GameManager extends Node2D

static var instance: GameManager;

var machines = [
	preload('res://machines/BaseRobotCreator.tscn'),
	preload('res://machines/ReedirectMachine.tscn'),
	preload('res://machines/RobotAntennaAttacher.tscn'),
	preload('res://machines/PainterMachine.tscn'),
]

signal on_machine_switch

var selected_machine = machines[0]
var link_target: Building = null;
var _money: float = 0;


func add_money(value: float):
	_money += value;
	$CanvasLayer/VBoxContainer/MoneyLabel.text = "$" + str(round(_money))

func can_afford(cost: float) -> bool:
	return _money >= cost

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instance = self
	grid_helper.manager = self
		
	on_machine_switch.emit(selected_machine as PackedScene)	
	
	grid_helper.add_no_place_region(Vector2(10, 1), Vector2(15, 3))
	add_money(200)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$CanvasLayer/VBoxContainer/HBoxContainer/Clock.value = 100 - round(($"Day Timer".time_left/$"Day Timer".wait_time) * 100)

var last_mouse_position = Vector2(0,0)

func _input(event: InputEvent):
	var grid_position = grid_helper.from_screen_space($Camera2D.get_global_mouse_position());
	var pos = grid_helper.snap_to_grid($Camera2D.get_global_mouse_position());
	
	
	
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("move_screen"):
			$Camera2D.position += (last_mouse_position - event.position);
		last_mouse_position = event.position;
		$SelectionDisplay.position = pos
		$CursorLight.position = $Camera2D.get_global_mouse_position()
	
	if Input.is_action_just_released("move_screen"):
		return
	if Input.is_action_just_released("place"):
		var dummy_instance = (selected_machine.instantiate() as Building)
		if can_afford(dummy_instance.cost):
			if grid_helper.is_placable(grid_position):
				grid_helper.place_machine(selected_machine, grid_position)
				add_money(-dummy_instance.cost)
	if Input.is_action_just_pressed("link"):
		var cur_target = grid_helper.get_at_position(grid_helper.from_screen_space(pos)) as Building
		if cur_target != null && link_target == null && cur_target.can_link:
			link_target = cur_target
		else:
			if cur_target != null && link_target != null:
				print('linking')
				link_target.link(cur_target)
				link_target = null
	if Input.is_action_just_pressed("modify_placed"):
		if grid_helper.is_placable(grid_position):
			grid_helper.get_at_position(grid_position).modify()
	if Input.is_action_just_pressed("cycle_machines"):
		var idx = machines.find(selected_machine) + 1;
		if idx == machines.size():
			idx = 0;
		selected_machine = machines[idx]
		on_machine_switch.emit(selected_machine as PackedScene)
	
