extends Area2D

var speed = 1000
var id_player = -1

func _physics_process(delta):
	global_position.y += -speed * delta
	
func _on_PlayerLaser_area_entered(area):
	if area.is_in_group("enemies"):
		area.take_damage(1)
		get_node("/root/Mundo").pontos_player(id_player, 10)
		queue_free()


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func set_id_player(id):
	id_player = id
