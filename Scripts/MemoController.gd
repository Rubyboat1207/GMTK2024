class_name MemoController extends Control

@export var memo_titles_box: VBoxContainer

class Memo:
	var title: String;
	var text: String;
	var label: Label;
	
	func meets_criteria() -> bool:
		return true
	
	func _init(title, text):
		self.title = title;
		self.text = text;
	
	func on_activated():
		pass
	
	func post_activation():
		pass

class AttributeMemo extends Memo:
	var met_last = true;
	var _value;
	var _toy;
	var _attribute;
	
	func _init(toy: String, attribute: String, title: String, text: String, value) -> void:
		_toy = toy
		_attribute = attribute
		_value = value
		super(title, text)
	
	func meets_criteria() -> bool:
		var any_use_toy = false
		for link: Building in GameManager.instance.get_links_to_output():
			if link.output_type == _toy:
				any_use_toy = true
				break
		
		return met_last && any_use_toy
	
	func individual_item_meets(data: ItemData):
		met_last = data.get_attribute_value(_attribute) == _value;
		
		return met_last

class ValueRandomizer:
	
	func get_value():
		pass

class ValueRangeRandomizer extends ValueRandomizer:
	
	func _init(lower: float, upper: float, allow_floats: bool):
		self.lower = lower
		self.upper = upper
		self.allow_floats = allow_floats
	
	func get_value():
		if self.allow_floats:
			return randf_range(self.lower, self.upper)
		else:
			return randi_range(self.lower, self.upper)

class AttributeRandomizerMemo extends AttributeMemo:
	var _randomizer: ValueRandomizer;
	
	func _init(toy: String, attribute: String, title: String, text: String, randomizer: ValueRandomizer) -> void:
		_randomizer = randomizer
		super(toy, attribute, title, text, null)
	
	func on_activated():
		_value = _randomizer.get_value()
		
		text.replace('%s', str(_value))

class ConveyorMemo extends Memo: 
	var dist: float;
	var meets = true;
	
	func _init(title: String, text: String):
		dist = randi_range(3, 9) * 100
		super(title.replace('%s', str(round(dist / 10))), text.replace('%s', str(round(dist / 10))))
	
	func meets_criteria() -> bool:
		return meets
	
	func recalculate():
		var machines = GameManager.instance.get_node("GridChildrenContainer").get_children()
		
		var total_dist = 0
		var connected_machines = 0
		for machine: Building in machines:
			if machine.out_link == null:
				continue
			connected_machines += 1;
			total_dist += machine.precalculated_distance
		
		if connected_machines == 0:
			connected_machines = 1
		var avg = total_dist / connected_machines
		meets = abs(avg - dist) < 100
		
		if label != null:
			label.text = title + " is "+str(round(avg / 10))+"m"
	
	func post_activation():
		recalculate()

var message_memos = [
	Memo.new("intro", "Hello, welcome to the HappyHands family! Get to work. Your job is to send completed products to the trucks in the lot. I've been told by HR to expect the least out of you. I would advise you to ignore any and all complaints about me changing scope you may have seen online, those employees are all babies.")
]

var memos: Array[Memo] = [
	AttributeMemo.new('robot', 'Antena', 'All Robots must have antennas', 
		'Hey, You know these robots are supposed to have WiFi right? Customers have been complaining and claiming "false advertising." You have to keep up with whatever garbage the marketing team is throwing on social media. I\'m ignoring quality assurance because I really don\'t want to deal with them. Put antennas on \'em... somewhere.',
		true),
	AttributeMemo.new('robot', 'Face', 'All Robots must have faces', 
		"Teenagers love our robots, but I've been thinking that we need to appeal to younger demographics. Wouldn't be too hard to put faces on all these little guys leaving the factory, right? Look, I'll be real, Sharon told me she wants a raise during the last management cruise. I'm only gonna shoot my shot once there's numbers to back that up, so get to it.",
		true),
	AttributeMemo.new('robot', 'arms', 'All Robots must have arms', 
		'I\'ve been thinking... Know what these robots are really missing? ARMS. I think it would make them so much more lifelike, can you just make this small change? I just told Gertrude in operations that they already have them, so make it quick.',
		true),
	AttributeMemo.new('robot', 'arms', 'All Cars must have big wheels', 
		'I\'ve been thinking... Know what these robots are really missing? ARMS. I think it would make them so much more lifelike, can you just make this small change? I just told Gertrude in operations that they already have them, so make it quick.',
		true),
	ConveyorMemo.new('Avg. belt length must be ~%sm', 
		"Turns out, there's new legistlation about how long your conveyors have to be. My hands are tied on this one, so just make sure that they remain around the legal limits. Also make sure to let me know if theres anyone snooping around, keep this between us but me and the tax man aren't on good terms right now.")
]

var inactive_memos = []

var active_memos = []

signal on_stopped_meeting_criteria
signal started_meeting_criteria

var was_meeting_criteria = true

func meets_criteria() -> bool:
	for memo: Memo in active_memos:
		if !memo.meets_criteria():
			return false
	return true

func periodic_signal_update():
	var meets = meets_criteria()
	update_memo_visual()
	if meets:
		if !was_meeting_criteria:
			started_meeting_criteria.emit()
		was_meeting_criteria = true
		
			
	elif was_meeting_criteria:
		stopped_meeting_criteria()
		was_meeting_criteria = false
	

func show_memo(memo: Memo):
	$MemoAnimator/MemoContainer/MemoPaper/MemoText.text = memo.text
	$MemoAnimator.play('appear')
	get_tree().create_timer((memo.text.split(' ').size() / 150.0) * 60).timeout.connect(hide_memo)

func hide_memo():
	$MemoAnimator.play('leave')

func add_memo(memo: Memo):
	memo.on_activated()
	show_memo(memo)
	active_memos.append(memo)
	inactive_memos.remove_at(inactive_memos.find(memo))
	var label = preload('res://RequirementLabel.tscn').instantiate();
	memo.label = label
	label.text = memo.title
	memo_titles_box.add_child(label)
	periodic_signal_update()
	memo.post_activation()

func _ready() -> void:
	show_memo(message_memos[0])
	
	inactive_memos = memos

func _on_day_timer_timeout():
	for memo: Memo in active_memos:
		if !memo.meets_criteria():
			GameManager.instance.add_money(-500)
		else:
			GameManager.instance.add_money(50)
	
	add_memo(inactive_memos.pick_random())


func _on_item_processed(machine: OutputMachine, item: Node2D):
	periodic_signal_update()
	update_memo_visual()
	
	for memo in active_memos:
		if memo is AttributeMemo:
			if !memo.individual_item_meets(item):
				machine.cancel_transaction = true
				GameManager.instance.add_money(-50, false, item.global_position + Vector2(0, -70))

func stopped_meeting_criteria():
	on_stopped_meeting_criteria.emit()
	

func update_memo_visual():
	for memo: Memo in active_memos:
		if !memo.meets_criteria():
			memo.label.set('theme_override_colors/font_color', Color('#b0493b'))
		else:
			memo.label.set('theme_override_colors/font_color', Color('#44ab50'))


func _on_game_manager_link_attempted():
	for memo: Memo in active_memos:
		if memo is ConveyorMemo:
			memo.recalculate()
