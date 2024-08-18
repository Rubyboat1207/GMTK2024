extends Building

func can_accept_item(other: Building):
	return true

signal item_processed

func input_item(item: Node2D):
	held_item = null
	item_processed.emit(item)
	item.queue_free()
	
	if item is ItemData:
		GameManager.instance.add_money(item.get_value())
