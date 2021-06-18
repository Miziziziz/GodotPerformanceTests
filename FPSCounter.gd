extends Label


func _process(delta):
	text = str(Engine.get_frames_per_second())
