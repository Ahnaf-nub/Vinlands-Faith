extends CharacterBody2D

@export var speed: float = 100

var player = null
var can_attack = true
var health = 100
var player_inattack_zone = false
var took_damage_recently = false

@onready var detection_area: Area2D = $enemy_hitbox
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var damage_cooldown: Timer = $"../damage_cooldown"
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_attacking = false  # Track if the boss is attacking

func _ready():
	for body in get_tree().get_nodes_in_group("CharacterBody2D"):
		if body.name == "CharacterBody2D":  # Ensure it's the main character
			player = body
			break

func _process(delta):
	if is_attacking:
		return  # Prevent movement while attacking

	deal_with_damage()

	if player:
		if can_attack and is_colliding_with_player():
			perform_attack()
		else:
			move_toward_player(delta)

func _on_area_2d_body_entered(body):
	if body.name == "CharacterBody2D":
		player = body
		player_inattack_zone = true

func _on_area_2d_body_exited(body):
	if body.name == "CharacterBody2D":
		player = null
		player_inattack_zone = false
		anim_sprite.play("idle")  # Return to idle when the player leaves attack range

func deal_with_damage():
	if player_inattack_zone and Global.current_attack and not took_damage_recently:
		health -= 10
		print("Boss health = ", health)
		took_damage_recently = true
		damage_cooldown.start()  # Start cooldown timer

		if health <= 0:
			queue_free()

func _on_damage_cooldown_timeout():
	took_damage_recently = false

func move_toward_player(delta):
	if player and not is_attacking:
		var direction = (player.global_position - global_position).normalized()
		velocity.x = direction.x * speed
		move_and_slide()

		if direction.x < 0:
			anim_sprite.flip_h = true
		elif direction.x > 0:
			anim_sprite.flip_h = false

		anim_sprite.play("walk")

func perform_attack():
	# Don't attack if already attacking or not allowed to attack
	if not can_attack or is_attacking:
		return

	# Boss starts attacking
	is_attacking = true
	can_attack = false
	velocity = Vector2.ZERO  # Stop movement
	anim_sprite.stop()  # Stop any conflicting animation

	print("Boss is attacking!")
	animation_player.play("attack")  # Play attack animation via AnimationPlayer

	await animation_player.animation_finished
	print("Boss attack animation finished!")

	# Reset after attack is done
	is_attacking = false  # Allow for new attack
	await get_tree().create_timer(1.0).timeout  # Attack cooldown
	can_attack = true

# Check if boss is colliding with player
func is_colliding_with_player() -> bool:
	var collision = detection_area.get_overlapping_bodies()
	return player in collision

func _on_animated_sprite_2d_animation_finished(anim_name: String):
	if anim_name == "attack":
		can_attack = true  # Allow attacking again after animation finishes
		print("Attack animation finished, ready to attack again.")
