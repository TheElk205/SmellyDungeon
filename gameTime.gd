extends Label

@export var label: Label
var time_elapsed = 0.0
var minutes = 0.0
var seconds = 0.0
var milliseconds = 0.0
var time_string = "00:00"

func _process(delta: float):
	time_elapsed += delta
	minutes = time_elapsed / 60
	seconds = fmod(time_elapsed, 60)
	milliseconds = fmod(time_elapsed, 1) * 100
	time_string = "%02d:%02d:%02d" % [minutes, seconds, milliseconds]
	label.text = time_string
	


func _on_tree_exiting() -> void:
	GlobalData.elapsedTime = milliseconds
	GlobalData.elapsedTimeString = time_string
