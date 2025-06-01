extends CharacterBody2D

@export var waypointObjects: Array[NodePath]

var movement_speed: float = 50.0
var follow_speed: float = 115.0
var current_movement_speed = 0
var rng = RandomNumberGenerator.new()
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var animationSprite:AnimatedSprite2D = $AnimatedSprite2D
@onready var visionBar: ProgressBar = $VisionBar

var walkTowards: Vector2
var waypoints: Array[Vector2]
var currentWaypointIndex: int = 0
var toFollow: CharacterBody2D = null
var startedFollowingAt = 0
var maxFollowingTime = 4.0
var distracted = false
var targetVisible = false

func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 2.0
	navigation_agent.target_desired_distance = 2.0
	navigation_agent.debug_enabled = true
	animationSprite.play("walk")
	visionBar.max_value = maxFollowingTime
	visionBar.visible = false
	movement_speed = rng.randf_range(50.0, 100.0)
	current_movement_speed = movement_speed
	print("Rat ready: ", movement_speed)
	
	for index in waypointObjects.size():
		waypoints.append((get_node_or_null(waypointObjects[index]) as Node2D).transform.origin)
	
	print("Found waypoints: ", waypoints.size())
	if waypoints.size() > 0:
		walkTowards = waypoints[currentWaypointIndex]
		navigation_agent.target_position = walkTowards
	
func _physics_process(_delta):
	if navigation_agent.is_navigation_finished():
		return

	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()

	var velocityDiff = velocity
	velocity = current_agent_position.direction_to(next_path_position) * current_movement_speed
	velocityDiff = velocityDiff - velocity
	#animationSprite.flip_h = velocity.x < 0
	#self.global_rotation = (Vector2(1.0, 1.0) - velocity).angle()
	self.global_rotation =  velocity.angle()
	
	move_and_slide()

func _process(delta: float) -> void:
	#print(self.transform.origin.distance_to(walkTowards))
	if self.transform.origin.distance_to(walkTowards) < 2:
		print("Point reached")
		print("Current waypoint index: ", currentWaypointIndex)
		currentWaypointIndex = rng.randi_range(0, waypoints.size()-1)
		print("Updated waypoint index: ", currentWaypointIndex)
		walkTowards = waypoints[currentWaypointIndex]
		navigation_agent.target_position = walkTowards
	if toFollow != null:
		navigation_agent.target_position = toFollow.global_position
	if !targetVisible and visionBar.visible:
		visionBar.value = maxFollowingTime - (Time.get_ticks_msec() - startedFollowingAt) / 1000.0
		if visionBar.value <= 0:
			navigation_agent.target_position = waypoints[currentWaypointIndex]
			visionBar.visible = false
			toFollow = null
			current_movement_speed = movement_speed

func _on_nose_area_entered(area: Area2D) -> void:
	print("something smelly....", area.get_parent().name) 
	if area.get_parent().name.begins_with("Cheese"):
		print("Distracted")
		navigation_agent.target_position = area.get_parent().global_position
		distracted = true
		toFollow = null
		targetVisible = false
		visionBar.visible = false
		current_movement_speed = movement_speed

func _on_nose_area_exited(area: Area2D) -> void:
	navigation_agent.target_position = waypoints[currentWaypointIndex]
	distracted = false
	

func _on_eyes_area_entered(area: Area2D) -> void:
	if area.get_parent().name == "Character" and !distracted:
		print("Start following")
		visionBar.visible = true
		visionBar.value = maxFollowingTime
		toFollow = area.get_parent()
		startedFollowingAt = Time.get_ticks_msec()
		targetVisible = true
		current_movement_speed = follow_speed
		# Replace with function body.


func _on_eyes_area_exited(area: Area2D) -> void:
	if area.get_parent().name == "Character":
		print("Stop following")
		targetVisible = false
