extends Node2D

var spawn_positions = null

var Enemy = preload("res://characters/enemy/Enemy.tscn")
var EnemyCol = preload("res://EnemyCol.tscn")

var enemies = []

var speed = 150
var wait_time = 3

func _ready():
	randomize()
	
func spawn_enemy():
	if get_node("/root/Mundo").id_client != -1:
		var enemy = EnemyCol.instance()
		enemy.speed = speed
		speed += 5
		enemy.global_position.y = 0
		enemy.global_position.x = randi() % 440
		enemies.push_front(enemy)
		add_child(enemy)
		if wait_time > 0.5:
			wait_time -= 0.05
			$SpawnTimer.wait_time = wait_time

func kill_all():
	speed = 150
	for enemy in enemies:
		if enemy != null and weakref(enemy).get_ref():
			enemy.take_damage()
	enemies = []

func atualizar_prox_col():
	enemies.pop_back()

func _on_SpawnTimer_timeout():
	 spawn_enemy()
