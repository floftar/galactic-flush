# https://www.youtube.com/watch?v=FmIo8iBV1W8

extends Node2D

@onready var lasers = $Lasers
@onready var player = $Player
@onready var asteroids = $Asteroids
@onready var hud = $UI/HUD
@onready var game_over_screen = $UI/GameOverScreen
@onready var player_spawn_pos = $PlayerSpawnPos
@onready var player_spawn_area = $PlayerSpawnPos/PlayerSpawnArea
@onready var toilet = $Toilet

var asteroid_scene = preload("res://scenes/asteroid.tscn")
var explosion_scene = preload("res://scenes/explosion.tscn")
var angry_poo_scene = preload("res://scenes/angry_poo.tscn")

var score: int:
	set(value):
		score = value
		hud.score = score

var lives: int:
	set(value):
		lives = value
		hud.init_lives(value)
		
var angry_poo_active = false

func _ready():
	game_over_screen.visible = false
	
	score = 0
	lives = 1
	
	player.connect("laser_shot", _on_player_laser_shot)
	player.connect("died", _on_player_died)
	
	for asteroid in asteroids.get_children():
		asteroid.connect("exploded", _on_asteroid_exploded)
		
	toilet.connect("toilet_hit", _on_toilet_hit)
	
	# "Preload"
	explosion(Vector2(-100, 100))
	
func _on_player_laser_shot(laser):
	$LaserSound.play()
	lasers.add_child(laser)

func _process(_delta):
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()

func _on_asteroid_exploded(pos, size, points):
	score += points
	
	match size:
		Asteroid.AsteroidSize.LARGE:
			$AsteroidHitSound.play()
			explosion(pos)
			
			for i in range(2):
				spawn_asteroid(pos, Asteroid.AsteroidSize.MEDIUM)
		Asteroid.AsteroidSize.MEDIUM:
			$AsteroidHitSound.play()
			explosion(pos)
			
			for i in range(2):
				spawn_asteroid(pos, Asteroid.AsteroidSize.SMALL)
		Asteroid.AsteroidSize.SMALL:
			$AsteroidDestroySound.play()
			explosion(pos)
			spawn_asteroid_from_toilet(pos, Asteroid.AsteroidSize.LARGE)

func spawn_asteroid(pos, size):
	var a = asteroid_scene.instantiate()
	a.global_position = pos
	a.size = size
	a.connect("exploded", _on_asteroid_exploded)
	asteroids.call_deferred("add_child", a)
	
func spawn_asteroid_from_toilet(_pos, size):
	var a = asteroid_scene.instantiate()
	a.global_position = toilet.position
	a.size = size
	a.connect("exploded", _on_asteroid_exploded)
	asteroids.call_deferred("add_child", a)
	
func _on_toilet_hit():
	$ToiletHitSound.play()
	
	if not angry_poo_active:
		angry_poo_active = true
		$AngryPooHitSound.play()

		var a = angry_poo_scene.instantiate()
		a.global_position = toilet.position
		a.set_random_direction()
		a.connect("angry_poo_hit", _on_angry_poo_hit)
		call_deferred("add_child", a)
	
func _on_angry_poo_hit():
	$AngryPooHitSound.play()
	
func explosion(pos):
	var e = explosion_scene.instantiate()
	e.global_position = pos
	asteroids.call_deferred("add_child", e)

func _on_player_died():
	$PlayerDieSound.play()
	explosion(player.global_position)
	lives -= 1
	
	player.global_position = player_spawn_pos.global_position
	
	if lives <= 0:
		await get_tree().create_timer(2).timeout
		game_over_screen.visible = true
	else:
		await get_tree().create_timer(1).timeout
		
		while !player_spawn_area.is_empty:
			await get_tree().create_timer(0.1).timeout
		
		player.respawn(player_spawn_pos.global_position)
