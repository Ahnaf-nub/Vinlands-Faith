extends Area2D

func _on_body_entered(body):
	if body.name == "CharacterBody2D":
		call_deferred("restart_level") 

func restart_level():
	get_tree().reload_current_scene()  # Restart level safely
