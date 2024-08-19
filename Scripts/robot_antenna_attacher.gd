extends Building

@export var attribute: String = 'Antena';
@export var input_type: String = 'robot';

func mutate_item(item: Node2D) -> Node2D:
	(item.get_node(attribute) as Sprite2D).show()
	(item.get_node(attribute) as ItemData).is_added = true;
	
	return item

func can_accept_item(builder: Building) -> bool:
	if super(builder):
		return builder.output_type == 'robot'
	return false
