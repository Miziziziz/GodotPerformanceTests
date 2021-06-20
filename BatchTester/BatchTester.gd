extends Control

var scene_count
var scenes = []
var dirs = []
var roots = {}
var current_dir
var current
var results = {}
var fps_samples = []

onready var start_button : Button = $"MarginContainer/VBoxContainer2/VBoxContainer/HBoxContainer/StartButton"
onready var test_option_button : OptionButton = $"MarginContainer/VBoxContainer2/VBoxContainer/HBoxContainer/TestOptionButton"
onready var stop_button : Button = $"MarginContainer/VBoxContainer2/VBoxContainer/HBoxContainer/StopButton"
onready var viewport : Viewport = $"MarginContainer/VBoxContainer2/MarginContainer/ViewportContainer/Viewport"
onready var next_button : Button = $"MarginContainer/VBoxContainer2/VBoxContainer/HBoxContainer/NextButton"
onready var current_test_label : Label = $"MarginContainer/VBoxContainer2/VBoxContainer/CurrentTestLabel"
onready var result_tree : Tree = $"MarginContainer/VBoxContainer2/MarginContainer/ResultTree"
onready var time_spin_box : SpinBox = $"MarginContainer/VBoxContainer2/VBoxContainer/HBoxContainer2/TimeSpinBox"
onready var next_test_timer : Timer = $NextTestTimer
onready var run_all_button : Button = $"MarginContainer/VBoxContainer2/VBoxContainer/HBoxContainer/RunAllButton"
onready var test_progress_bar : ProgressBar = $"MarginContainer/VBoxContainer2/VBoxContainer/Progress/TestProgressBar"
onready var progress : Control = $"MarginContainer/VBoxContainer2/VBoxContainer/Progress"
onready var get_fps_timer : Timer = $GetFPSTimer

func _ready() -> void:
	set_process(false)
	result_tree.set_column_titles_visible(true)
	result_tree.set_column_title(0, "Test")
	result_tree.set_column_title(1, "FPS")
	result_tree.create_item()


func _process(_delta : float) -> void:
	test_progress_bar.max_value = (scene_count - 1) * time_spin_box.value + next_test_timer.wait_time
	test_progress_bar.value = (scene_count - scenes.size() - 1) * time_spin_box.value + next_test_timer.wait_time - next_test_timer.time_left


func start_tests(test_dir):
	scenes.clear()
	results[test_dir] = []
	var dir = Directory.new()
	var test_folder = "res://".plus_file(test_dir)
	current_dir = test_dir
	dir.open(test_folder)
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		var file = test_folder.plus_file(file_name)
		if ResourceLoader.exists(file, "PackedScene"):
			scenes.append(load(file).instance())
		file_name = dir.get_next()
	scene_count = scenes.size()
	stop_button.show()
	next_button.show()
	progress.show()
	current_test_label.show()
	result_tree.hide()
	start_next_test()
	set_process(true)


func start_next_test():
	if current:
		var test_name = current.filename.get_basename().get_file()
		if not fps_samples.empty():
			var sum_fps = 0
			for fps in fps_samples:
				sum_fps += fps
			results[current_dir].append({
				name = test_name,
				time = sum_fps / fps_samples.size(),
			})
		viewport.remove_child(current)
	if scenes.empty():
		finish_testing()
		return
	current = scenes.pop_front()
	current_test_label.text = "Currently testing %s" % current.filename.get_basename().get_file()
	viewport.add_child(current)
	fps_samples.clear()
	next_button.disabled = scenes.empty()
	next_test_timer.start(time_spin_box.value)
	yield(get_tree().create_timer(1.0), "timeout")
	get_fps_timer.start()


class ResultSorter:
	static func sort_by_time_ascending(a, b):
		return a.time < b.time


func finish_testing():
	if not current:
		return
	stop_button.hide()
	next_button.hide()
	progress.hide()
	current_test_label.hide()
	next_test_timer.stop()
	get_fps_timer.stop()
	if current.get_parent():
		viewport.remove_child(current)
	current.queue_free()
	set_process(false)
	current = null
	scenes.clear()
	results[current_dir].sort_custom(ResultSorter.new(), "sort_by_time_ascending")
	var root : TreeItem = roots.get(current_dir)
	if not root:
		root = result_tree.create_item(result_tree.get_root())
		root.set_text(0, current_dir)
		roots[current_dir] = root
	var child = root.get_children()
	while child != null:
		root.remove_child(child)
		child = child.get_next()
	for test in results[current_dir]:
		var item = result_tree.create_item(root)
		item.set_text(0, test.name)
		item.set_text(1, str(test.time))
		if test == results[current_dir].back():
			item.set_custom_color(0, Color.lightgreen)
			item.set_custom_color(1, Color.lightgreen)
	result_tree.show()
	next_dir()


func next_dir():
	if dirs.empty():
		return
	start_tests(dirs.pop_front())


func _on_StartButton_pressed() -> void:
	if current:
		finish_testing()
	start_tests(test_option_button.text)


func _on_StopButton_pressed() -> void:
	dirs.clear()
	viewport.remove_child(current)
	finish_testing()


func _on_NextButton_pressed() -> void:
	start_next_test()


func _on_NextTestTimer_timeout() -> void:
	start_next_test()


func _on_RunAllButton_pressed() -> void:
	finish_testing()
	dirs.clear()
	for item_num in test_option_button.get_item_count():
		dirs.append(test_option_button.get_item_text(item_num))
	next_dir()


func _on_CopyResultsButton_pressed() -> void:
	var markdown = "# Results\n"
	for dir in results:
		markdown += "\n## %s\n\n| Test | FPS |\n| --- | --- |\n" % dir
		for test in results[dir]:
			var elements = [test.name, test.time]
			if test == results[dir].back():
				for element_num in elements.size():
					elements[element_num] = "**%s**" % elements[element_num]
			markdown += "| %s | %s |\n" % elements
	OS.clipboard = markdown


func _on_GetFPSTimer_timeout() -> void:
	fps_samples.append(Engine.get_frames_per_second())


func _on_CopyCSVButton_pressed() -> void:
	var csv = "Test Name,FPS,Test Suite\n"
	for dir in results:
		for test in results[dir]:
			csv += "%s,%s,%s\n" % [test.name, test.time, dir]
	OS.clipboard = csv
