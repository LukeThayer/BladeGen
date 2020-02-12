extends Actor


puppet var repl_jump = 0
puppet var repl_right = 0
puppet var repl_left = 0
onready var camera = get_node("Camera2D")


func _ready() -> void:
	if(is_network_master()):
		camera.make_current()








func set_dominant_color(color):
	$Sprite.modulate = color



func _physics_process(delta: float) -> void:
	var pressedJump : bool = 0
	var pressedRight : int = 0
	var pressedLeft : int= 0
	if (is_network_master()):
		# Initialize the movement vector
		
		pressedJump = Input.get_action_strength("jump")
		pressedRight = Input.get_action_strength("move_right")
		pressedLeft = Input.get_action_strength("move_left")
	
		
		# Replicate the input
		
		rset("repl_jump", pressedJump)
		rset("repl_left", pressedLeft)
		rset("repl_right", pressedRight)
		
		
	else:
		# Take replicated variables to set current actor state
		pressedJump = repl_jump
		pressedLeft = repl_left
		pressedRight = repl_right
		
	
	var direction: = getWalkDirection(pressedRight,pressedLeft,pressedJump)
	var jumpInterrupted: = !pressedJump and velocity.y < 0
	velocity = calc_Velocity(direction,maxSpeed,velocity,jumpInterrupted)
	velocity = move_and_slide(velocity, FLOOR_NORMAL)





	Input.get_action_strength("move_left")
	

func getWalkDirection(right : int, left: int, jump : bool) -> Vector2:
	return Vector2(
	right- left,
	-1.0 if jump and is_on_floor() else 1.0)


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

