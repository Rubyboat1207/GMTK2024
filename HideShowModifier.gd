extends Building

@export var attributes: Array[String] = ['Body', "Wheels"];
@export var hide: Array[String] = ["BigWheels"];
@export var input_type: String = 'robot';

func mutate_item(item: Node2D) -> Node2D:
	for attribute in attributes:
		(item.get_node(attribute) as Sprite2D).show()
		(item.get_node(attribute) as ItemData).is_added = true;
	
	for attribute in hide:
		(item.get_node(attribute) as Sprite2D).hide()
		(item.get_node(attribute) as ItemData).is_added = false;
	
	return item

func can_accept_item(builder: Building) -> bool:
	if super(builder):
		return builder.output_type == 'robot'
	return false
