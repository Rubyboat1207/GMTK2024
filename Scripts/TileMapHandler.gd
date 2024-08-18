extends TileMapLayer

@export var source_id: int = 5  # The TileSetSource identifier
@export var atlas_coords: Vector2i = Vector2i(0, 0)  # The coordinates in the atlas
@export var alternative_tiles: int = 3  # The alternative tile identifier
@export var inner_radius: float = 15.0  # The radius within which to place tiles
@export var outer_radius: float = 20.0  # The radius outside which tiles will be removed

@export var player: Node2D = null  # The player node, set this in the editor or dynamically

func noise(x, y, upper_bound):
	var value = (x * 374761393 + y * 668265263) & 0xFFFFFFFF
	value ^= (value >> 13)
	value ^= (value << 17)
	value ^= (value >> 5)
	return (value % upper_bound)

func random_id(x, y):
	return noise(x, y, alternative_tiles)

# This function is called every frame to update the tile map based on the player's position
func _process(delta: float) -> void:
	if player == null:
		return  # No player assigned, so we exit the function
	
	# Get the player's position in tilemap coordinates
	var player_position = local_to_map(player.global_position)
	
	# Calculate the bounds for tile placement and removal
	var inner_radius_squared = inner_radius * inner_radius
	var outer_radius_squared = outer_radius * outer_radius
	
	# Loop through a square of tiles around the player
	for y in range(-outer_radius, outer_radius):
		for x in range(-outer_radius, outer_radius):
			var tile_position = Vector2i(x, y) + player_position
			
			var distance_squared = (tile_position - player_position).length_squared()
			if distance_squared <= inner_radius_squared:
				# Inside the inner radius, ensure the tile is placed
				if get_cell_source_id(tile_position) == -1:
					set_cell(tile_position, source_id, atlas_coords, random_id(tile_position.x, tile_position.y))
			elif distance_squared > outer_radius_squared:
				# Outside the outer radius, ensure the tile is removed
				if get_cell_source_id(tile_position) != -1:
					set_cell(tile_position, -1)
