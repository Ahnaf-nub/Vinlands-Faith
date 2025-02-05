extends Sprite2D

func _ready() -> void:
	$Area2D.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "CharacterBody2D":
		print("Player entered the door")

		# Update the current level dynamically
		Global.update_current_level(get_tree().current_scene.scene_file_path)

		# Get the next level
		var next_scene = Global.next_levels.get(Global.current_level, "")

		# If a next level exists, switch to it
		if next_scene != "":
			print("Switching to:", next_scene)
			Global.current_level = next_scene  # Update before changing scene
			call_deferred("change_scene", next_scene)
		else:
			print("No next level found! Game might be finished.")

func change_scene(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)
