class_name MemoController extends Control

class Memo:
	var title: String;
	var text: String;
	
	func meets_criteria() -> bool:
		return true
	
	func _init(title, text):
		self.title = title;
		self.text = text;

class AttributeMemo extends Memo:
	var toy: String;
	var attribute: String;
	
	func _init(toy: String, attribute: String, title: String, text: String, value) -> void:
		self.toy = toy
		self.attribute = attribute
		super(title, text)
	

var message_memos = [
	Memo.new("intro", "Hello, welcome to the HappyHands family! Get to work. Your job is to send completed products to the trucks in the lot. I've been told by HR to expect the least out of you. I would advise you to ignore any and all complaints about me changing scope you may have seen online, those employees are all babies.")
]

var memos: Array[Memo] = [
	AttributeMemo.new('robot', 'antenna', 'All Robots must have antenna', 
		'Hey, You know these robots are supposed to have WiFi right? Customers have been complaining and claiming "false advertising." You have to keep up with whatever garbage the marketing team is throwing on social media. I\'m ignoring quality assurance because I really don\'t want to deal with them. Put antennas on \'em... somewhere.',
		true),
	AttributeMemo.new('robot', 'arms', 'All Robots must have antenna', 
		'I\'ve been thinking... Know what these robots are really missing? ARMS. I think it would make them so much more lifelike, can you just make this small change? I just told Gertrude in operations that they already have them, so make it quick.',
		true)
]

var active_memos = []

func meets_criteria() -> bool:
	for memo: Memo in active_memos:
		if !memo.meets_criteria():
			return false
	return true

func show_memo(memo: Memo):
	$MemoAnimator/MemoPaper/MemoText.text = memo.text
	$MemoAnimator.play('appear')

func _ready() -> void:
	show_memo(message_memos[0])
