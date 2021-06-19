extends Spatial

signal timed_out

func _ready():
	$Timer.connect("timeout", self, "emit_timed_out")

func init():
	$Particles.restart()

func emit_timed_out():
	emit_signal("timed_out")
