extends Node2D

var spawn_positions = null

var Player = preload("res://characters/player/Player.tscn")

func _ready():
	randomize()
	spawn_positions = $SpawnPositions.get_children()
	
func spawn_player():
	print("Nasceu")
	var player = Player.instance()
	player.global_position = spawn_positions[0].global_position
	add_child(player)

func _on_Timer_timeout():
	spawn_player()
