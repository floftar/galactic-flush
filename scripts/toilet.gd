class_name Toilet extends Area2D

signal toilet_hit()

func _on_body_entered(body):
	if body is Player:
		var player = body
		player.die()

func hit():
	emit_signal("toilet_hit")
