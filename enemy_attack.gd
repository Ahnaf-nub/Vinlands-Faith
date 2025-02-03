extends CharacterBody2D

@onready var gamemanager: Node = %Gamemanager
@export var speed: float = 50.0
@export var gravity: float = 900.0

@onready var animated_sprite: AnimatedSprite2D = $Area2D/AnimatedSprite2D
@onready var attack_timer: Timer = $Timer
@onready var detection_area: Area2D = $Area2D

var dir: Vector2 = Vector2.RIGHT
var is_attacking: bool = false
var player_inside: bool = false  # Track if player is inside detection area

func _ready():
	attack_timer.start()
	animated_sprite.play("walk")

func _on_timer_timeout():
	if not is_attacking:
		pick_new_direction()

@export var direction_change_interval: float = 2.0  # Time interval for direction change
var last_direction_change_time: float = 0.0  # Track the last time direction changed

func pick_new_direction():
	if Time.get_ticks_msec() / 1000.0 - last_direction_change_time < direction_change_interval:
		return  # Wait for the interval before changing direction

	last_direction_change_time = Time.get_ticks_msec() / 1000.0  # Update last change time

	dir = choose([Vector2.RIGHT, Vector2.LEFT])
	update_flip()
	velocity.x = dir.x * speed
	animated_sprite.play("walk")

func choose(array):
	array.shuffle()
	return array.front()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta  

	if not is_attacking:
		velocity.x = dir.x * speed
		animated_sprite.play("walk")  
	else:
		velocity.x = 0  

	move_and_slide()

func update_flip():
	if not is_attacking:
		animated_sprite.flip_h = (dir.x < 0)

func _on_body_entered(body):
	if body.name == "CharacterBody2D":
		player_inside = true
		if not is_attacking:
			attack()

func _on_body_exited(body):
	if body.name == "CharacterBody2D":
		player_inside = false
		is_attacking = false  
		attack_timer.stop()  
		pick_new_direction()  # ✅ Immediately pick a new direction
		attack_timer.start(2.0)  # ✅ Restart the timer to resume movement

func attack():
	if is_attacking:
		return

	is_attacking = true
	gamemanager.call_deferred("decrease_health")
	velocity.x = 0  
	animated_sprite.play("attack")
	attack_timer.start(0.8)  # Attack duration

func _on_attack_timer_timeout():
	if player_inside:
		attack()  
	else:
		is_attacking = false
		pick_new_direction()  # ✅ Restart patrolling correctly
		attack_timer.start(2.0)  # ✅ Restart the timer so movement resumes
