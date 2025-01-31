extends Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect the body_entered signal of the Area2D using a Callable
	$Area2D.body_entered.connect(_on_body_entered)

func _on_body_entered(body) -> void:
	# Check if the body is the character (optional)
	if body.name == "CharacterBody2D":  # Replace "Character" with your player's node name
		print("went")
