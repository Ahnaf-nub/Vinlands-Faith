extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var jumping: AudioStreamPlayer = $Jumping
@onready var attacking: AudioStreamPlayer = $Attacking
@onready var falling: AudioStreamPlayer = $Falling
@onready var running: AudioStreamPlayer = $Running

const SPEED = 250.0
const JUMP_VELOCITY = -400.0
const WALL_JUMP_FORCE = 350.0 # Adjusted for wall jumping
const FALL_THRESHOLD = 1200.0 # Y position below which the character will restart

var start_position = Vector2.ZERO
var on_rope: bool = false
var enemy_inattack_range = false
var enemy_attack_cooldown = true
var health = 100
var is_attacking = false
var double_jump = 0
var last_direction = 1 # 1 = Right, -1 = Left

func _ready() -> void:
	start_position = position

func jump():
	velocity.y = JUMP_VELOCITY
	jumping.play()

func jump_side(x):
	velocity.y = JUMP_VELOCITY
	velocity.x = x

func _physics_process(delta: float) -> void:
	enemy_attack()

	if health <= 0:
		health = 0
		sprite.play("death")
		return

	# Handle movement
	var direction := Input.get_axis("left", "right")
	var touching_wall = is_on_wall() and not is_on_floor()

	if !is_attacking:
		if direction != 0:
			velocity.x = direction * SPEED
			last_direction = direction
			if !running.playing:
				running.play()
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			running.stop()

	# Handle animations
	if velocity.x != 0 and !is_attacking:
		sprite.play("run")
	elif !is_attacking:
		sprite.play("idle")

	# Apply Gravity
	if !is_on_floor() and !on_rope and !is_attacking:
		velocity += get_gravity() * delta
		if velocity.y > 0:
			sprite.play("fall")
			if !falling.playing:
				falling.play()
		else:
			sprite.play("jump")

	# Handle rope movement
	if on_rope and !is_attacking:
		if Input.is_action_pressed("down"):
			velocity.y = SPEED * delta * 15
			sprite.play("ladder")
		elif Input.is_action_pressed("jump"):
			velocity.y = -SPEED * delta * 15
			sprite.play("ladder")
		else:
			velocity.y = 0

	# Jump input handling
	if Input.is_action_just_pressed("jump") and !is_attacking:
		if is_on_floor():
			double_jump = 1
			jump()
		elif touching_wall:
			if direction == 0:  # Neutral wall jump (jump straight up)
				velocity.y = JUMP_VELOCITY
			else:  # Wall jump away
				velocity.y = JUMP_VELOCITY
				velocity.x = -last_direction * WALL_JUMP_FORCE
		elif double_jump == 1:
			double_jump = 2
			jump()

	# Reset double jump when landing
	if is_on_floor() and velocity.y == 0:
		double_jump = 0

	# Flip sprite based on last movement direction
	sprite.flip_h = last_direction < 0
	
	# Handle attacking
	if Input.is_action_just_pressed("attack") and not is_attacking:
		is_attacking = true
		Global.current_attack = true
		animation_player.play("attack")
		attacking.play()
		velocity.x = 0
		velocity.y = 0
		
	move_and_slide()

	# Check if the character falls below the threshold.
	if position.y > FALL_THRESHOLD:
		restart()

func restart() -> void:
	position = start_position
	velocity = Vector2.ZERO

func _on_rope_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		on_rope = true

func _on_rope_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
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

func _on_cooldown_timeout() -> void:
	enemy_attack_cooldown = true

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack":
		is_attacking = false
		Global.current_attack = false
