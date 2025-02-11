extends Area2D  # Pressure Plate must be an Area2D

@onready var sprite_2d: AnimatedSprite2D = $Sprite2D

@export var door: Node2D  # Assign the door in the Inspector
@export var press_duration: float = 3.0  # Time the door stays open

var is_activated = false  # Prevent multiple triggers

func _on_body_entered(body: Node2D) -> void:
	if body.name == "CharacterBody2D" and not is_activated:
		is_activated = true  # Mark as activated
		sprite_2d.play("pressed")  # Change to pressed animation
		door.open_door()
		await get_tree().create_timer(press_duration).timeout  # Wait for the duration
		door.close_door()  # Manually close the door after the timer
		sprite_2d.play("default")  # Change back to default animation
		is_activated = false  # Reset after time expires

func _on_body_exited(body: Node2D) -> void:
	if body.name == "CharacterBody2D" and is_activated:
		sprite_2d.play("default")  # Change back to default animation
