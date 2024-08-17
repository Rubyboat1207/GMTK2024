class_name Building extends Node2D

@export var can_link_to = true
@export var can_link = true
@export var cooldown = 1.0
@export var prefab: PackedScene;
@export var output_type: String = "";

class ConveyorItem:
	var progress: int;
	var item: Node2D;
	
	func _init(item_in: Node2D):
		progress = 0;
		item = item_in

var conveyor_items: Array[ConveyorItem] = [];

var line_renderer: Line2D;

var cooldown_timer = 0.0

var out_link: Building = null
var precalculated_distance: float;

var held_item: Node2D = null;

func link(other: Building):
	if other == self || other == null:
		line_renderer.points = []
		out_link = null
	elif other.can_link:
		out_link = other
		
		line_renderer.points = []
		line_renderer.add_point(Vector2(0,0))
		line_renderer.add_point(out_link.position - self.position)
		
		precalculated_distance = self.position.distance_to(out_link.position)
	
	for item in conveyor_items:
		item.item.queue_free()
	
	conveyor_items = []

func _ready():
	line_renderer = $LinkVisual

func _process(delta: float):
	cooldown_timer += delta
	
	if out_link != null:
		print(cooldown_timer)
		if out_link.can_accept_item(self):
			if cooldown_timer > cooldown:
				if can_output_item():
					output_item()
					cooldown_timer = delta
				
			for item in conveyor_items:
				item.progress += delta * 100
				
				if item.progress >= precalculated_distance:
					out_link.input_item(item.item)
					conveyor_items.remove_at(conveyor_items.find(item))
				
				print(item.progress + delta * 100)
				item.item.position = Vector2(0,0).lerp((out_link.position - self.position), item.progress / precalculated_distance)


func mutate_item(item: Node2D) -> Node2D:
	return item


func output_item():
	var modified_item: Node2D;
	if prefab != null:
		modified_item = mutate_item(prefab.instantiate())
	else:
		modified_item = held_item
		held_item = null
	
	if modified_item.get_parent() != null:
		modified_item.reparent($ConveyorContainer)
	else:
		$ConveyorContainer.add_child(modified_item)
	
	conveyor_items.append(ConveyorItem.new(modified_item))

func can_output_item() -> bool:
	if prefab != null || held_item != null:
		return out_link != null
	return false

func can_accept_item(builder: Building) -> bool:
	if held_item == null:
		return true
	return false

func input_item(item):
	held_item = mutate_item(item)
