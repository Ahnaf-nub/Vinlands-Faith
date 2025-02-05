extends Node2D

@export var move_distance: float = 100  # How far the spike moves down
@export var move_speed: float = 0.5  # Time taken to move up/down
@export var wait_time: float = 1.5  # Delay before switching direction

var start_position: Vector2
var target_position: Vector2
var moving_down: bool = true

@onready var timer: Timer = $Timer

func _ready():
	start_position = global_position
	target_position = start_position + Vector2(0, move_distance)
	move_spike()

func move_spike():
	var tween = create_tween()
	if moving_down:
		tween.tween_property(self, "global_position", target_position, move_speed)
	else:
		tween.tween_property(self, "global_position", start_position, move_speed)
	
	moving_down = !moving_down
	await tween.finished
	timer.start(wait_time)
	await timer.timeout
	move_spike()
