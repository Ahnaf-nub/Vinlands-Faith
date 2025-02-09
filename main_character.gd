extends CharacterBody2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
const SPEED = 250.0
const JUMP_VELOCITY = -400.0
const FALL_THRESHOLD = 1200.0 # Y position below which the character will restart
var start_position = Vector2.ZERO # Starting position for the character
var on_rope: bool = false
var enemy_inattack_range = false
var enemy_attack_cooldown = true
var health = 100
var is_attacking = false
var double_jump = 0
var last_direction = 1  # 1 = Right, -1 = Left

func _ready() -> void:
	# Store the starting position of the character
	start_position = position
	
func jump():
	velocity.y = JUMP_VELOCITY
	
func jump_side(x):
	velocity.y = JUMP_VELOCITY
	velocity.x = x

func _physics_process(delta: float) -> void:
	enemy_attack()

	if health <= 0:
		health = 0
		sprite.play("death")
		return

	# Handle movement first
	var direction := Input.get_axis("left", "right")
	if !is_attacking:
		if direction != 0:
			velocity.x = direction * SPEED
			last_direction = direction  # Store last facing direction
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	# Handle animations
	if velocity.x != 0 and !is_attacking:
		sprite.play("run")
	else:
		if !is_attacking:
			sprite.play("idle")

	# Handle jumping
	if !is_on_floor() and !on_rope and !is_attacking:
		velocity += get_gravity() * delta
		if velocity.y > 0:
			sprite.play("fall")
		else:
			sprite.play("jump")

	# Handle rope movement
	if on_rope and is_attacking == false:
		if Input.is_action_pressed("down"):
			velocity.y = SPEED * delta * 15
			sprite.play("ladder")
		elif Input.is_action_pressed("jump"):
			velocity.y = -SPEED * delta * 15
			sprite.play("ladder")
		else:
			velocity.y = 0

	# Jump input handling
	if Input.is_action_just_pressed("jump") and is_attacking == false:
		if is_on_floor():
			double_jump = 1  # Reset double jump when on the floor
			velocity.y = JUMP_VELOCITY
		elif double_jump == 1:
			double_jump = 2  # Allow second jump
			velocity.y = JUMP_VELOCITY
	
	# Ensure double jump resets properly when landing
	if is_on_floor() and velocity.y == 0:
		double_jump = 0

	# Flip sprite based on last movement direction (persist even when idle)
	sprite.flip_h = last_direction < 0
	
	if Input.is_action_just_pressed("attack") and not is_attacking:
		is_attacking = true
		Global.current_attack = true
		animation_player.play("attack")
		
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

func _on_player_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_inattack_range = true

func _on_player_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_inattack_range = false

func enemy_attack():
	if enemy_inattack_range and enemy_attack_cooldown:
		health -= 10
		enemy_attack_cooldown = false
		$cooldown.start()
		print(health)

func player():
	pass

func _on_cooldown_timeout() -> void:
	enemy_attack_cooldown = true

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack":
		is_attacking = false
		Global.current_attack = false
