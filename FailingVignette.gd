extends TextureRect


func _on_memo_controller_on_stopped_meeting_criteria():
	visible = true


func _on_memo_controller_started_meeting_criteria():
	visible = false
