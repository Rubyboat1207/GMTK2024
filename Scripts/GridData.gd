class_name grid_helper
static var manager: GameManager = null;
static var cell_size: int = 150;

static var no_place_regions: Array = []

static func get_at_position(grid_position: Vector2):
	var expected_pos = from_grid_space(grid_position)
	for child: Node2D in manager.get_node('GridChildrenContainer').get_children():
		if child.position == expected_pos:
			return child
	return null

static func get_current_grid_selection():
	return from_screen_space((manager.get_node("Camera2D") as Camera2D).get_global_mouse_position());

static func from_screen_space(screen_position):
	return round(screen_position / cell_size);

static func snap_to_grid(screen_position):
	return from_grid_space(from_screen_space(screen_position))
	
static func from_grid_space(grid_position: Vector2):	
	return Vector2(round(grid_position.x) * cell_size, round(grid_position.y) * cell_size)

static func place_machine(machine: PackedScene, grid_position: Vector2):
	var machine_inst = machine.instantiate() as Node2D
	manager.get_node('GridChildrenContainer').add_child(machine_inst)
	machine_inst.position = from_grid_space(grid_position)

static func is_placable(grid_position: Vector2):
	if get_at_position(grid_position):
		return false
	
	# Check if this position is within any no place region
	for region in no_place_regions:
		if is_within_region(grid_position, region[0], region[1]):
			return false
	
	return true

static func is_within_region(position: Vector2, start: Vector2, end: Vector2) -> bool:
	return position.x >= start.x and position.x <= end.x and position.y >= start.y and position.y <= end.y

static func add_no_place_region(point1: Vector2, point2: Vector2):
	point1 += Vector2.ONE
	point2 += Vector2.ONE
	var region_start = Vector2(min(point1.x, point2.x), min(point1.y, point2.y))
	var region_end = Vector2(max(point1.x, point2.x), max(point1.y, point2.y))
	no_place_regions.append([region_start, region_end])
