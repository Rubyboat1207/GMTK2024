extends TileMapLayer

@export var cell_size: Vector2 = Vector2(grid_helper.cell_size, grid_helper.cell_size)
var grid_size: Vector2 = Vector2(3, 3)

func _ready():
	grid_size = Vector2(int(grid_size.x) | 1, int(grid_size.y) | 1)
	_update_grid()

func _process(_delta):
	grid_size = ceil(get_viewport_rect().size / grid_helper.cell_size)
	_update_grid()

func _update_grid():
	var player_pos = get_viewport_rect().position
	var base_x = int(player_pos.x / cell_size.x)
	var base_y = int(player_pos.y / cell_size.y)
	
	for x in range(-int(grid_size.x / 2), int(grid_size.x / 2) + 1):
		for y in range(-int(grid_size.y / 2), int(grid_size.y / 2) + 1):
			var tile_x = base_x + x
			var tile_y = base_y + y
			
			var original_x = wrap_position(tile_x, get_used_rect().size.x)
			var original_y = wrap_position(tile_y, get_used_rect().size.y)
			
			if get_cell_source_id(Vector2(original_x, original_y)) != 0:
				print('setting cell')
				set_cell(Vector2i(tile_x, tile_y), get_cell_source_id(Vector2i(original_x, original_y)))

func wrap_position(pos, max_value):
	return (pos + max_value) % max_value
