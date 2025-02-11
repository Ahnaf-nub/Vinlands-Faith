extends Node

var previous_scene = ""  # For dimension switching
var current_level = ""  # Dynamically updates with the loaded level
var current_attack = false
var next_levels = {
	"res://levels/level1.tscn": "res://levels/level2.tscn",
	"res://levels/level2.tscn": "res://levels/level3.tscn",
	"res://levels/level3.tscn": "res://levels/level4.tscn",
	"res://levels/level4.tscn": "res://levels/level5.tscn",
	"res://levels/level5.tscn": "res://levels/final.tscn",
}

func update_current_level(scene_path: String) -> void:
	if scene_path in next_levels:
		current_level = scene_path
