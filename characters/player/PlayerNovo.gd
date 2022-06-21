extends Area2D
class_name PlayerNovo

const PORT = 9080
var _server = WebSocketServer.new()

var tela = [540 - 40, 960 - 40] 

signal spawn_laser(location)

var speed = 300

var input_vector = Vector2.ZERO

var hp = 1

var id_ind = 0

var fitness = 0
var vivo = 1

var dist_esq = 999
var dist_dir = 999
var dist_cima = 999
var dist_baixo = 999

var fenda_esq
var fenda_dir

func _physics_process(delta):
	input_vector.x = Input.get_action_strength("mover_direita") - Input.get_action_strength("mover_esquerda")
	#input_vector.y = Input.get_action_strength("mover_baixo") - Input.get_action_strength("mover_cima")
	
	global_position += input_vector * speed * delta
	
	
	dist_esq = global_position.x - 40
	dist_dir = tela[0] - global_position.x
	dist_cima = global_position.y - 40
	dist_baixo = tela[1] - global_position.y
	
	
	
	global_position.x =  tela[0] if global_position.x > tela[0] else global_position.x
	global_position.x =  40 if global_position.x < 40 else global_position.x
	
	
func take_damage(damage):
	hp -= damage
	if hp <= 0:
		#fitness -= 5
		vivo = 0
		notificar_dados()
		queue_free()


	
func get_position():
	return global_position

# Servidor WS #
func _ready():
	pass

func mover(mov):
	if mov == "md":
		global_position.x += 10
	elif mov == "me":
		global_position.x -= 10
	elif mov == "mc":
		global_position.y -= 5
	elif mov == "mb":
		global_position.y += 5
	elif mov == "at":
		#shoot_laser()
		pass

func notificar_dados():
	var msg = str(id_ind) + ":"\
		+ str(fitness) + ":"\
		+ str(vivo)
	var list_enemies = get_node("/root/Mundo/EnemySpawner").enemies
	var prox_col = list_enemies.back()
	var alt_col = 0
	var dist = 999
	fenda_dir = 999
	fenda_esq = 999
	if prox_col and weakref(prox_col).get_ref():
		fenda_esq = global_position.distance_to(prox_col.global_position)
		fenda_dir = global_position.distance_to(Vector2(prox_col.global_position.x, prox_col.global_position.y+185))
		alt_col = prox_col.global_position.x
		dist = global_position.y - prox_col.global_position.y
	msg += ":" + str(fenda_esq) + ":"\
		+ str(fenda_dir) + ":"\
		+ str(dist_esq) 
	
	get_node("/root/Mundo").notificar(msg)
	# fitness = 0
	get_node("/root/Mundo").show_fitness(fitness)

func set_id(id):
	id_ind = id
	
func get_id():
	return id_ind
	


func _on_Timer_timeout():
	notificar_dados()
