class_name ItemData extends Node2D

@export var individual_value = 15.0
@export var cost = 5.0
@export var type: String;

var is_added = false

func get_value() -> float:
	var total_value = individual_value;
	for child in get_children():
		if child is ItemData:
			if child.is_added:
				total_value += child.individual_value
	
	return total_value

func get_attribute_value(attr: String):
	if has_node(attr):
		var node = get_node(attr)
		
		if node is Sprite2D:
			if attr.ends_with(":color"):
				return node.self_modulate
			return node.visible
