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

class MonitoringMemo extends Memo:
	var history = [];
	var max_history_size = 20
	
	func individual_item_meets(data: ItemData) -> bool:
		return true
	
	func insert_historical_data(data: Node2D):
		history.insert(0, individual_item_meets(data))
		
		if history.size() > max_history_size:
			history.remove_at(max_history_size)
	
	func meets_criteria() -> bool:
		for entry in history:
			if !entry:
				print(entry, ' wasnt true')
				return false
		print('returning that i met criteria!')
		return true

class AttributeMemo extends MonitoringMemo:
	var toy: String;
	var attribute: String;
	var value;
	
	func _init(toy: String, attribute: String, title: String, text: String, value) -> void:
		self.toy = toy
		self.attribute = attribute
		self.value = value
		super(title, text)
	
	func insert_historical_data(data: Node2D):
		if data is ItemData:
			if data.type == toy:
				super(data)
	
	func individual_item_meets(data: ItemData):
		return data.get_attribute_value(attribute) == value
	

var message_memos = [
	Memo.new("intro", "Hello, welcome to the HappyHands family! Get to work. Your job is to send completed products to the trucks in the lot. I've been told by HR to expect the least out of you. I would advise you to ignore any and all complaints about me changing scope you may have seen online, those employees are all babies.")
]

var memos: Array[Memo] = [
	AttributeMemo.new('robot', 'Antena', 'All Robots must have antennas', 
		'Hey, You know these robots are supposed to have WiFi right? Customers have been complaining and claiming "false advertising." You have to keep up with whatever garbage the marketing team is throwing on social media. I\'m ignoring quality assurance because I really don\'t want to deal with them. Put antennas on \'em... somewhere.',
		true)
	#,
	#AttributeMemo.new('robot', 'arms', 'All Robots must have arms', 
		#'I\'ve been thinking... Know what these robots are really missing? ARMS. I think it would make them so much more lifelike, can you just make this small change? I just told Gertrude in operations that they already have them, so make it quick.',
		#true)
]

var inactive_memos = []

var active_memos = []

signal on_stopped_meeting_criteria

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
	show_memo(memo)
	active_memos.append(memo)
	inactive_memos.remove_at(inactive_memos.find(memo))
	var label = preload('res://RequirementLabel.tscn').instantiate();
	memo.label = label
	label.text = memo.title
	memo_titles_box.add_child(label)
	periodic_signal_update()

func _ready() -> void:
	show_memo(message_memos[0])
	
	inactive_memos = memos

func _on_day_timer_timeout():
	for memo: Memo in active_memos:
		if !memo.meets_criteria():
			GameManager.instance.add_money(-100)
		else:
			GameManager.instance.add_money(50)
	
	add_memo(inactive_memos.pick_random())


func _on_item_processed(item: Node2D):
	periodic_signal_update()
	
	for memo in active_memos:
		if memo is MonitoringMemo:
			memo.insert_historical_data(item)

func stopped_meeting_criteria():
	on_stopped_meeting_criteria.emit()
	
	update_memo_visual()

func update_memo_visual():
	for memo: Memo in active_memos:
		if !memo.meets_criteria():
			memo.label.set('theme_override_colors/font_color', Color('#b0493b'))
		else:
			memo.label.set('theme_override_colors/font_color', Color('#44ab50'))
