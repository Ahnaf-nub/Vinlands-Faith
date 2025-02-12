extends Node2D

@onready var collision_shape: CollisionShape2D = $AnimatedSprite2D/StaticBody2D/CollisionShape2D

@onready var door_open: AudioStreamPlayer = $door_open
@onready var door_close: AudioStreamPlayer = $door_close

var is_open = false  # Track door state

func _ready():
	# Ensure the door starts closed
	$AnimatedSprite2D.play("close")    
	collision_shape.set_deferred("disabled", false)  

func open_door():
	if is_open:
		return  # Prevent reopening while already open
	is_open = true  
	$AnimatedSprite2D.play("open")   
	door_open.play()
	collision_shape.set_deferred("disabled", true)  

func close_door():
	if not is_open:
		return  # Prevent closing if already closed
	is_open = false  
	$AnimatedSprite2D.play("close")    
	door_close.play()
	await get_tree().create_timer(0.5).timeout  
	collision_shape.set_deferred("disabled", false)  
