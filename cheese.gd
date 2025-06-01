extends CharacterBody2D
@onready var animationSprite:AnimatedSprite2D = $AnimatedSprite2D
@onready var timerBar: ProgressBar = $Timerbar

var cheeseLifetime = 6.0
var numberOfRats = 0
var startedEatingAt = 0

func _ready():
	animationSprite.play("idle")
	timerBar.max_value = cheeseLifetime
	timerBar.visible = false
	

func _process(delta: float) -> void:
	if numberOfRats > 0:
		timerBar.value = cheeseLifetime - (Time.get_ticks_msec() - startedEatingAt) * numberOfRats / 1000.0
		if timerBar.value <= 0:
			queue_free()
	

func _on_area_2d_area_entered(area: Area2D) -> void:
	print("Help, i am beeing eaten: ", area.get_parent().name)
	if area.get_parent().name.begins_with("Rat"):
		if (numberOfRats == 0):
			startedEatingAt = Time.get_ticks_msec()
		numberOfRats = numberOfRats + 1
		timerBar.visible = true
