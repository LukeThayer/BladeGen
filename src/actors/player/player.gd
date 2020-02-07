extends Actor

puppet var repl_position = Vector2()
onready var camera = get_node("Camera2D")


func _ready() -> void:
	if(is_network_master()):
		camera.make_current()








func set_dominant_color(color):
	$Sprite.modulate = color



func _physics_process(delta: float) -> void:
	if (is_network_master()):
		# Initialize the movement vector
		var move_dir = Vector2(0, 0)
		
		var direction: = getWalkDirection()
		var jumpInterrupted: = Input.is_action_just_released("Jump") and velocity.y < 0
		velocity = calc_Velocity(direction,maxSpeed,velocity,jumpInterrupted)
		velocity = move_and_slide(velocity, FLOOR_NORMAL)
		
		# Apply the movement formula to obtain the new actor position
		position += move_dir.normalized() * maxSpeed.x * delta
		
		# Replicate the position
		rset("repl_position", position)
	else:
		# Take replicated variables to set current actor state
		position = repl_position


func getWalkDirection() -> Vector2:
	return Vector2(
	Input.get_action_strength("move_right")- Input.get_action_strength("move_left"),
	-1.0 if Input.is_action_just_pressed("jump") and is_on_floor() else 1.0)


func calc_Velocity(
	direction: Vector2,
	speed: Vector2,
	linearVelocity: Vector2,
	jumpInterrupted: bool
	) -> Vector2:
	
	var newVelocity: = linearVelocity
	
	newVelocity.x = direction.x * speed.x
	newVelocity.y += gravity * get_physics_process_delta_time()
	if direction.y == -1:
		newVelocity.y = speed.y * direction.y
	if jumpInterrupted:
		newVelocity.y = 0.0
	
	return newVelocity

