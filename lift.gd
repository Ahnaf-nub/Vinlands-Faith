extends Node2D

@export var top_position: Vector2
@export var bottom_position: Vector2
@export var speed: float = 100.0

var moving: bool = false
var going_up: bool = false  # Start by going up first
var player_inside: bool = false  # Track if player is inside the lift

@onready var platform: StaticBody2D = $Platform
@onready var lift_sprite: AnimatedSprite2D = $Platform/AnimatedSprite
@onready var lift_trigger: Area2D = $LiftTrigger

func _ready():
	platform.position = bottom_position
	lift_sprite.play("open")  # Start with doors open

func _process(delta):
	if moving:
		move_lift(delta)

func move_lift(delta):
	var target_position = top_position if going_up else bottom_position
	var direction = (target_position - platform.position).normalized()
	platform.position += direction * speed * delta

	# Stop when reaching target position
	if platform.position.distance_to(target_position) < 2.0:
		platform.position = target_position
		moving = false
		if not player_inside:
			lift_sprite.play("open")  # Open doors only if no player is inside

func _on_lift_trigger_body_entered(body: Node2D) -> void:
	if body.name == "CharacterBody2D" and not moving:
		player_inside = true
		lift_sprite.play("close")  # Close doors before moving
		await get_tree().create_timer(0.5).timeout  # Small delay before moving
		moving = true
		going_up = not going_up  # Toggle direction

func _on_lift_trigger_body_exited(body: Node2D) -> void:
	if body.name == "CharacterBody2D":
		player_inside = false
		if not moving:
			lift_sprite.play("close")  # Open doors when player exits
