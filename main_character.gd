extends CharacterBody2D

const SPEED = 250.0
const JUMP_VELOCITY = -350.0
const FALL_THRESHOLD = 1200.0 # Y position below which the character will restart
var start_position = Vector2.ZERO # Starting position for the character
var on_rope:bool = false

func _ready() -> void:
	# Store the starting position of the character
	start_position = position
	
func jump():
	velocity.y = JUMP_VELOCITY
	
func jump_side(x):
	velocity.y = JUMP_VELOCITY
	velocity.x = x

func _physics_process(delta: float) -> void:
	if not is_on_floor() and !on_rope:
		velocity += get_gravity() * delta
	
	if on_rope:
		if Input.is_action_pressed("down"):
			velocity.y = SPEED*delta*15
		elif Input.is_action_pressed("jump"):
			velocity.y = -SPEED*delta*15
		else:
			velocity.y = 0
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	else:
		var direction := Input.get_axis("left", "right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# Check if the character falls below the threshold.
	if position.y > FALL_THRESHOLD:
		restart()

func restart() -> void:
	# Reset the character's position and velocity
	position = start_position
	velocity = Vector2.ZERO
	

func _on_rope_body_entered(body: Node2D) -> void:
	if "CharacterBody2D" in body.name:
		on_rope = true

func _on_rope_body_exited(body: Node2D) -> void:
	if "CharacterBody2D" in body.name:
		on_rope = false
