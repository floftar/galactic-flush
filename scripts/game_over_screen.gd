extends Control

@onready var sound := get_parent().get_parent().get_node("RestartSound")

func _on_restart_button_pressed():
	sound.play()
	await get_tree().create_timer(0.1).timeout
	get_tree().reload_current_scene()
