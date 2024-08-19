class_name OutputMachine extends Building

func can_accept_item(other: Building):
	
	return true

signal item_processed

var cancel_transaction = false

func input_item(item: Node2D):
	held_item = null
	cancel_transaction = false
	item_processed.emit(self, item)
	item.queue_free()
	if !cancel_transaction:	
		if item is ItemData:
			GameManager.instance.add_money(item.get_value(), false, position + Vector2(-30, -50))
