extends Spatial

export var item_path = ""
export var x_count = 1
export var y_count = 1
export var z_count = 1
export var spacing = 1


func _ready():
	var obj = load(item_path)
	for x in range(x_count):
		for y in range(y_count):
			for z in range(z_count):
				var inst = obj.instance()
				add_child(inst)
				inst.transform.origin = Vector3(x, y, z) * spacing
