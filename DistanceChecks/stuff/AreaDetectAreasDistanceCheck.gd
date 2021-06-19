extends Area

func _process(delta):
	if get_overlapping_areas().size() > 1:
		$Red.show()
		$Yellow.hide()
	else:
		$Red.hide()
		$Yellow.show()

