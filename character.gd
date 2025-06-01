extends CharacterBody2D


var movement_speed: float = 150.0
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var animationSprite:AnimatedSprite2D = $AnimatedSprite2D
@export var cheeseToPlace: PackedScene
@onready var healthBar = $HealthBar
var cheesePlacingTime = 1.5
var is_pressed = false
var placingTimeout = 50.0

var startPress = 0
func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 2.0
	navigation_agent.target_desired_distance = 2.0
	navigation_agent.debug_enabled = true
	print("Player ready")
	animationSprite.play("walk")
	healthBar.visible = false
	healthBar.max_value = cheesePlacingTime
	
# The "click" event is a custom input action defined in
# Project > Project Settings > Input Map tab.
func _unhandled_input(event):
	var duration = 0
	if event.is_action_pressed("click"):
		startPress = Time.get_ticks_msec()
		is_pressed = true
		pass
	elif event.is_action_released("click"):
		print("Released")
		is_pressed = false
		healthBar.visible = false
		duration = Time.get_ticks_msec() - startPress
		if duration < 100:
			set_movement_target(get_global_mouse_position())	

func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target


func _physics_process(_delta):
	if navigation_agent.is_navigation_finished():
		return

	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()

	velocity = current_agent_position.direction_to(next_path_position) * movement_speed
	animationSprite.flip_h = velocity.x < 0
		
	move_and_slide()

func _process(_delta):
	if is_pressed && placingTimeout < Time.get_ticks_msec() - startPress:
		navigation_agent.target_position = global_position
		healthBar.visible = true
	if is_pressed:
		var duration = Time.get_ticks_msec() - startPress + placingTimeout
		healthBar.value = duration / 1000.0
		print(duration)
		if duration > 1500:
			var cheese = cheeseToPlace.instantiate()
			self.get_parent().add_sibling(cheese)
			cheese.global_position = self.global_position
			healthBar.visible = false
			is_pressed = false
			
func _on_goal_area_entered(area: Area2D) -> void:
	if area.get_parent().name == "Character":
		GlobalData.reachedGoal = true
		get_tree().change_scene_to_file("res://GameOver.tscn")


func _on_catchable_area_area_entered(area: Area2D) -> void:
	print("Caught by: ", area.name)
	if  area.name == "Catch":
		get_tree().change_scene_to_file("res://GameOver.tscn")
