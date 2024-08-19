class_name Building extends Node2D

@export var can_link_to = true
@export var can_link = true
@export var cooldown = 1.0
@export var prefab: PackedScene;
@export var output_type: String = "";
@export var line_offset: Vector2;
@export var take_type_of_link = false;
@export var cost = 0;
var display = false

class ConveyorItem:
	var progress: int;
	var item: Node2D;
	
	func _init(item: Node2D):
		self.progress = 0;
		self.item = item

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
		line_renderer.add_point(line_offset)
		line_renderer.add_point((out_link.position + out_link.line_offset) - self.position)
		
		precalculated_distance = self.position.distance_to(out_link.position + out_link.line_offset)
		
		if other.position > position:
			set_flipped(true)
		else:
			set_flipped(false)
		
		if other.take_type_of_link:
			other.output_type = output_type
	else:
		print('link refused by host')
	
	for item in conveyor_items:
		item.item.queue_free()
	
	conveyor_items = []

func _ready():
	line_renderer = $LinkVisual
	if has_node("AnimationPlayer"):
		$AnimationPlayer.play("pop")

func set_hidden():
	$Sprite2D.hide()

func set_shown():
	$Sprite2D.show()

func set_alpha(alpha: float):
	$Sprite2D.self_modulate.a = alpha

func set_flipped(flip_h):
	$Sprite2D.flip_h = flip_h

func _physics_process(delta):
	cooldown_timer += delta
	
	
	
	if out_link != null:
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
				
				item.item.position = line_offset.lerp(((out_link.position + out_link.line_offset) - self.position), item.progress / precalculated_distance)
		else:
			cooldown_timer == 0

func modify():
	pass

func _process(delta):
	if get_viewport().get_camera_2d().get_global_mouse_position().distance_to(global_position) < 200:
		$Sprite2D/NameLabel.visible = true
	else:
		$Sprite2D/NameLabel.visible = false
		

func mutate_item(item: Node2D) -> Node2D:
	return item

var hard_mode = false

func output_item():
	var modified_item: Node2D;
	if prefab != null:
		modified_item = mutate_item(prefab.instantiate())
		if modified_item is ItemData:
			if hard_mode:
				if GameManager.instance.can_afford(modified_item.cost):
					GameManager.instance.add_money(-modified_item.cost, false, position + Vector2(0, -70))
				else:
					held_item = modified_item
					return
	else:
		modified_item = held_item
		if modified_item.get_parent() == null:
			if hard_mode:
				if !GameManager.instance.can_afford(held_item.cost):
					return
				else:
					GameManager.instance.add_money(-modified_item.cost, false, position + Vector2(0, -70))
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
