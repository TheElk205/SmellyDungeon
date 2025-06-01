extends Control

@onready var credits: NinePatchRect = $CreditsContainer
@onready var version: Label = $VersionLabel

func _ready():
	credits.visible = false
	version.text = ProjectSettings.get_setting("application/config/version")
	
func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://navigation.tscn")
	

func _on_tree_entered() -> void:
	GlobalData.reset()

func _on_credits_pressed() -> void:
	credits.visible = true


func _on_close_credits_pressed() -> void:
	credits.visible = false
