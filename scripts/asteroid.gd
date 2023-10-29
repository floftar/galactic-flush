class_name Asteroid extends Area2D

signal exploded(pos, size, points)

var movement_vector := Vector2(0, -1)

enum AsteroidSize{LARGE, MEDIUM, SMALL}
@export var size := AsteroidSize.LARGE

var speed := 50

@onready var sprite = $Sprite2D
@onready var cshape = $CollisionShape2D

var points: int:
	get:
		match size:
			AsteroidSize.LARGE:
				return 1
			AsteroidSize.MEDIUM:
				return 2
			AsteroidSize.SMALL:
				return 3
			_:
				return 0

func _ready():
	rotation = randf_range(0, 2 * PI)
	
	match size:
		AsteroidSize.LARGE:
			speed = randi_range(50, 100)
			sprite.texture = preload("res://assets/textures/poo-large.png")
			cshape.set_deferred("shape", preload("res://resources/poo_cshape_large.tres"))
		AsteroidSize.MEDIUM:
			speed = randi_range(100, 150)
			sprite.texture = preload("res://assets/textures/poo-medium.png")
			cshape.set_deferred("shape", preload("res://resources/poo_cshape_medium.tres"))
		AsteroidSize.SMALL:
			speed = randi_range(150, 200)
			sprite.texture = preload("res://assets/textures/poo-small.png")
			cshape.set_deferred("shape", preload("res://resources/poo_cshape_small.tres"))

func _physics_process(delta):
	global_position += movement_vector.rotated(rotation) * speed * delta

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

func explode():
	emit_signal("exploded", global_position, size, points)
	queue_free()

func _on_body_entered(body):
	if body is Player:
		var player = body
		player.die()
