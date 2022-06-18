extends Node2D

var spawn_positions = null

var Enemy = preload("res://characters/enemy/Enemy.tscn")

var enemies = []

var speed = 150

func _ready():
	randomize()
	spawn_positions = $SpawnPositions.get_children()
	
func spawn_enemy():
	if get_node("/root/Mundo").id_client != -1:
		var index = randi() % spawn_positions.size()
		var enemy = Enemy.instance()
		enemy.speed = speed
		speed += 5
		enemy.global_position.y = 0
		enemy.global_position.x = randi() % 540 
		enemies.append(enemy)
		add_child(enemy)

func kill_all():
	speed = 150
	for enemy in enemies:
		enemy.kill()


func _on_SpawnTimer_timeout():
	 spawn_enemy()
