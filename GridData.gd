class_name grid_helper
static var manager: GameManager = null;
static var cell_size: int = 50;

static func get_at_position(grid_position: Vector2):
	var expected_pos = from_grid_space(grid_position)
	print('expected pos', expected_pos)
	for child: Node2D in manager.get_node('GridChildrenContainer').get_children():
		print(child.position)
		if child.position == expected_pos:
			return child
	return null

static func from_screen_space(screen_position):
	return (screen_position / cell_size);

static func snap_to_grid(screen_position):
	return from_grid_space(from_screen_space(screen_position))
	
static func from_grid_space(grid_position: Vector2):	
	return Vector2(round(grid_position.x) * cell_size, round(grid_position.y) * cell_size)

static func place_machine(machine: PackedScene, grid_position: Vector2):
	var machine_inst = machine.instantiate() as Node2D
	manager.get_node('GridChildrenContainer').add_child(machine_inst)
	machine_inst.position = from_grid_space(grid_position)
