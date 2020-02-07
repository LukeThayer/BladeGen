extends Actor
onready var hitBox = get_node("HitBox")
onready var damagebox : Area2D = $polygons/Skeleton2D/hip/Spine/bicept_right/elbow_right/sword/DamageBox
onready var animPlayer = get_node("AnimationPlayer")
onready var sprite = get_node("polygons")
signal TookDamage

func _ready() -> void:
	animPlayer.connect("animation_started",self,"attackEnded")
	damagebox.connect("body_entered", self,"actorHit")

func attackEnded() -> void:
	damagebox.set_collision_mask_bit(1,false)
	
func actorHit(body)->void:
	body.changeHealth(-10)
	

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("click"):
		clickAction()
	var direction: = getWalkDirection()
	var jumpInterrupted: = Input.is_action_just_released("Jump") and velocity.y < 0
	velocity = calc_Velocity(direction,maxSpeed,velocity,jumpInterrupted)
	velocity = move_and_slide(velocity, FLOOR_NORMAL)
	UpdateLookDirection()
	if not animPlayer.is_playing():
		attackEnded()
	
	
func clickAction() -> void:
	var mouseCoord = get_global_mouse_position()

	var selfCoord = self.position
	
	if mouseCoord.y > selfCoord.y + 25:
		animPlayer.play("topAttack")
	elif mouseCoord.y < selfCoord.y - 25:
		animPlayer.play("midAttack")
	else:
		animPlayer.play("spin")
	damagebox.set_collision_mask_bit(1,true)
	
	

func UpdateLookDirection():
	var mouseCoord = get_global_mouse_position()
	var selfCoord = self.position
	if mouseCoord.x < selfCoord.x:
		sprite.set_scale(Vector2(-1,1))
	else:
		sprite.set_scale(Vector2(1,1))
		 
func getWalkDirection() -> Vector2:
	return Vector2(
	Input.get_action_strength("Move_right")- Input.get_action_strength("Move_left"),
	-1.0 if Input.is_action_just_pressed("Jump") and is_on_floor() else 1.0)

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
	
func ChangeHealth(change: int):
	var _HPSys = get_node("HealthSystem")
	_HPSys.adjustHealth(change)
	emit_signal("TookDamage")
