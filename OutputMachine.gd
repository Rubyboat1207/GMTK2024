extends Building

func can_accept_item(other: Building):
	return true

func input_item(item: Node2D):
	held_item = null
	item.queue_free()
