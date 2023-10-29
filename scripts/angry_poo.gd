class_name AngryPoo extends Area2D

signal angry_poo_hit()

var movement_vector := Vector2(0, 0)
var speed := 50

@onready var cshape = $CollisionShape2D
@onready var player := get_parent().get_node("Player")

func _ready():
	scale = Vector2(1, 1)

func _physics_process(delta):
	global_position += movement_vector * speed * delta

	var screen_size = get_viewport_rect().size
	var radius = cshape.shape.radius

	if global_position.y + radius < 0:
		global_position.y = screen_size.y + radius
	elif global_position.y - radius > screen_size.y:
		global_position.y = -radius

	if global_position.x + radius < 0:
		global_position.x = screen_size.x + radius
	elif global_position.x - radius > screen_size.x:
		global_position.x = -radius

func set_random_direction():
	movement_vector = Vector2(randf_range(0.1, 1), randf_range(0.1, 1))

func hit():
	emit_signal("angry_poo_hit")
	scale += Vector2(1.2, 1.2)
	
	var dx = player.position.x - global_position.x
	var dy = player.position.y - global_position.y
	var angle = atan2(dy, dx)
	
	movement_vector = Vector2(cos(angle), sin(angle))
	speed *= 2
	
func _on_body_entered(body):
	if body is Player:
		var p = body
		p.die()
