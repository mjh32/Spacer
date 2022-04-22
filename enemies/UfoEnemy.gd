extends Area2D

signal dead

export (int) var speed = 50
export (String, "left", "right", "debug") var state = "left"
onready var softCollision = $SoftCollision
onready var enemyLaser = preload("res://enemies/projectiles/EnemyLaser.tscn")

const defaultPos = Vector2(160,69)
const wanderLimit = 310
const wanderMin = 10
const killLimit = 330
const killMin = -10

var hp = 5
var rng = RandomNumberGenerator.new()
var hangAround = 0

func _ready( ):
	rng.randomize()

func _physics_process(delta):
	#global_position.y += speed * delta
	if (state == "left"):
		global_position.x -= speed * delta
		if (global_position.x <= wanderMin and hangAround < 6):
			state = "right"
			hangAround += 1
		elif (global_position.x <= killMin and hangAround >= 6):
			queue_free()
	elif (state == "right"):
		global_position.x += speed * delta
		if (global_position.x >= wanderLimit and hangAround < 6):
			state = "left"
			hangAround += 1
		elif (global_position.x >= killLimit and hangAround >= 6):
			queue_free()
	if (rng.randi_range(1, 1500) == 112):
		shoot()

func shoot():
	var el = enemyLaser.instance()
	var guns = [$Gun1, $Gun2, $Gun3]
	var selected = rng.randi_range(0, 2)
	el.global_position = guns[selected].global_position
	el.state = "aim"
	var currentScene = get_tree().get_current_scene()
	currentScene.add_child(el)

func take_damage(damage):
	hp -= damage
	if hp <= 0:
		emit_signal("dead")
		queue_free()

func _on_UfoEnemy_area_entered(area):
	if area is Player:
		area.take_damage(1)
