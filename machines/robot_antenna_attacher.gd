extends Building

func mutate_item(item: Node2D) -> Node2D:
	(item.get_node('Antena') as Sprite2D).show()
	(item.get_node('Antena') as ItemData).is_added = true;
	
	return item

func can_accept_item(builder: Building) -> bool:
	if super(builder):
		return builder.output_type == 'robot'
	return false
