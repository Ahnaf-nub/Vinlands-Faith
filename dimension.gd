extends Sprite2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "CharacterBody2D":
		# Get the current scene path
		var current_scene = get_tree().current_scene.scene_file_path

		# Check if we are in a dimension or a normal level
		var is_dimension = current_scene.begins_with("res://levels/new_dimension")

		# If we are in a dimension, return to the previous level
		# Otherwise, go to the dimension and store the current scene
		var next_scene = Global.previous_scene if is_dimension else "res://levels/new_dimension.tscn"

		# Store the last scene before switching
		Global.previous_scene = current_scene
	
		get_tree().change_scene_to_file(next_scene)
