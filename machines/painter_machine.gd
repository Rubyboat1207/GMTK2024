extends Building

@export var colors: Array[Color] = [
	Color(0,1,1,1)
]

func _ready():
	super()
	$Sprite2D/Color.self_modulate = colors[0]

func mutate_item(item: Node2D) -> Node2D:
	for child: Sprite2D in item.get_children():
		if child.visible:
			child.self_modulate = $Sprite2D/Color.self_modulate
	
	return item

func can_accept_item(builder: Building) -> bool:
	if super(builder):
		return builder.output_type == 'robot'
	return false

func set_alpha(alpha: float):
	super(alpha)
	$Sprite2D/Color.modulate.a = alpha

func set_flipped(flip_h):
	super(flip_h)
	
	$Sprite2D/Color.flip_h = flip_h

func modify():
	var color_idx = colors.find($Sprite2D/Color.self_modulate) + 1;
	if color_idx == colors.size():
		color_idx = 0
	$Sprite2D/Color.self_modulate = colors[color_idx];
