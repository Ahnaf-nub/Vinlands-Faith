extends CharacterBody2D

@onready var gamemanager: Node = %Gamemanager
@export var speed: float = 50.0
@export var gravity: float = 900.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_timer: Timer = $AttackTimer
@onready var detection_area: Area2D = $Area2D
@onready var raycast: RayCast2D = $AnimatedSprite2D/RayCast2D

var dir: Vector2 = Vector2.RIGHT
var is_attacking: bool = false
var player_inside: bool = false

func _ready():
	attack_timer.start()
	animated_sprite.play("walk")
	update_ray_direction()  # Ensure RayCast2D faces the correct direction

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta  

	if not is_attacking:
		if raycast.is_colliding():  
			pick_new_direction()  # Change direction on obstacle detection
		velocity.x = dir.x * speed
		animated_sprite.play("walk")  
	else:
		velocity.x = 0  

	move_and_slide()

func pick_new_direction():
	dir *= -1  # Reverse direction
	update_flip()
	if raycast and is_inside_tree():
		update_ray_direction()

	await get_tree().process_frame  # ✅ Ensure it updates on the next frame
	if raycast and is_inside_tree():
		raycast.force_raycast_update()



func update_flip():
	if not is_attacking:
		animated_sprite.flip_h = (dir.x < 0)

func update_ray_direction():
	if not is_inside_tree():  
		return  # ✅ Prevent updating before it's fully inside the tree

	if raycast:
		raycast.target_position.x = 10 if dir.x > 0 else -10  
		raycast.force_raycast_update()


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
		pick_new_direction()
		attack_timer.start(2.0)

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
		pick_new_direction()
		attack_timer.start(2.0)
