extends Control

@export var label: Label
@export var win: Label

func _ready():
	label.text = GlobalData.elapsedTimeString
	if GlobalData.reachedGoal:
		win.text = "Congratulations!\nMaze solved"
	
func _on_back_to_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://MainMenu.tscn")
