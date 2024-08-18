extends Area2D

var out = true

func _on_mouse_entered():
	if not out:
		slide_in()

func _on_mouse_exited():
	if out:
		slide_out()

func slide_out():
	out = false
	get_parent().play("SlideOut")

func slide_in():
	out = true
	get_parent().play("SlideIn")
