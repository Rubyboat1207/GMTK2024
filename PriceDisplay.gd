extends Label


func _on_timer_timeout():
	queue_free()

func _ready():
	$AnimationPlayer.play("fade-in-out")
