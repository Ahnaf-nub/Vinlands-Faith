extends CharacterBody2D

class_name Enemy
@onready var gamemanager: Node = %Gamemanager
@export var speed: float = 50.0
@export var gravity: float = 900.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_timer: Timer = $Timer
@onready var detection_area: Area2D = $Area2D

var dir: Vector2 = Vector2.RIGHT
var is_attacking: bool = false
var player_inside: bool = false  # Track if player is inside detection area

func _ready():
	$Timer.start()
	animated_sprite.play("walk")

func _on_timer_timeout():
	if not is_attacking:
		dir = choose([Vector2.RIGHT, Vector2.LEFT])
		update_flip()

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
		is_attacking = false  # Stop attack state immediately
		attack_timer.stop()  # Cancel any attack timer
		animated_sprite.play("walk")  # Resume walking

func attack():
	if is_attacking:  # Prevent multiple attacks
		return

	is_attacking = true
	gamemanager.decrease_health()
	velocity.x = 0  
	animated_sprite.play("attack")
	# Start attack duration (0.8s for 4 frames at 5 FPS)
	attack_timer.start(0.8)  

# 🚀 After Attack, Only Re-Attack if Player is Still Inside
func _on_attack_timer_timeout():
	if player_inside:
		attack()  # Only attack again if player is still there
	else:
		is_attacking = false
		animated_sprite.play("walk")  # Resume patrolling
