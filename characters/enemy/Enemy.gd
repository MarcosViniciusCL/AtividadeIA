extends Area2D
 

export (int) var speed = 150

signal colisao_posicao(location)

var hp = 1
var direcao = -2
var player = null

func _ready():
	direcao  = randi() % 3

func _physics_process(delta):
	global_position.y += speed * delta
	if direcao == 0:
		global_position.x -= randi() % 30 * delta
	if direcao == 2:
		global_position.x += randi() % 30 * delta
		
	
func take_damage(damage):
	hp -= damage
	if hp <= 0:
		#get_node("/root/PlayerLaser").enemies.pop(self)
		queue_free()

func get_position():
	return global_position

func kill():
	queue_free()
	


func _on_Enemy_area_entered(area):
	if area is Player:
		player = area
	# emit_signal("colisao_posicao", global_position)


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_Timer_timeout():
	var dist
	if(player != null and weakref(player).get_ref()):
		dist = global_position.distance_to(player.get_position())
	
		if dist < 80:
			player.take_damage(1)
			take_damage(1)
