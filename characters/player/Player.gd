extends Area2D
class_name Player

const PORT = 9080
var _server = WebSocketServer.new()

var tela = [540 - 40, 960 - 40] 


var sensor = [-1, -1, -1]
var obj_enemies = [null, null, null]

signal spawn_laser(location)

onready var muzzle = $Muzzle

var speed = 300

var input_vector = Vector2.ZERO

var hp = 1

var id_ind = 0

var fitness = 0
var vivo = 1
var borda = 0

var enemies_dead_per_time = 0
var shoot_count = 0

var quant_balas = 100
var dist_esq = 999
var dist_dir = 999
var dist_cima = 999
var dist_baixo = 999

func _physics_process(delta):
	input_vector.x = Input.get_action_strength("mover_direita") - Input.get_action_strength("mover_esquerda")
	input_vector.y = Input.get_action_strength("mover_baixo") - Input.get_action_strength("mover_cima")
	
	global_position += input_vector * speed * delta
	
	if Input.is_action_just_pressed("atirar"):
		shoot_laser()
	
	if (global_position.x < 42 or global_position.x > tela[0]-2 or global_position.y < 42 or  global_position.y > tela[1]-2):
		borda = 1
	else:
		borda = 0
	
	global_position.x =  tela[0] if global_position.x > tela[0] else global_position.x
	global_position.x =  40 if global_position.x < 40 else global_position.x
	global_position.y =  tela[1] if global_position.y > tela[1] else global_position.y
	global_position.y =  40 if global_position.y < 40 else global_position.y
	
	dist_esq = global_position.x - 40
	dist_dir = tela[0] - global_position.x
	dist_cima = global_position.y - 40
	dist_baixo = tela[1] - global_position.y
	
	
func take_damage(damage):
	hp -= damage
	if hp <= 0:
		fitness -= 15
		vivo = 0
		notificar_dados()
		queue_free()

func free():
	vivo = 0
	notificar_dados()
	queue_free()

func _on_Player_area_entered(area):
	var obj = area.get_position()
	if obj.x < global_position.x - 20:
		obj_enemies[0] = area
	elif obj.x > global_position.x + 20:
		obj_enemies[2] = area
	else:
		obj_enemies[1] = area

	if area.is_in_group("enemies") and global_position.distance_to(obj) < 50.0:
		area.take_damage(1)

func shoot_laser():
	# emit_signal("spawn_laser", global_position, id_ind)
	shoot_count += 1
	if quant_balas > 0:
		quant_balas -= 1
		get_node("/root/Mundo").shoot_laser(muzzle.global_position, id_ind)
	
func get_position():
	return global_position

# Servidor WS #
func _ready():
	
	pass


func notificar_dados():
	var sen = str(sensor[0]) + "," + str(sensor[1]) + "," + str(sensor[2])
	var msg = str(id_ind) + ":"\
		+ sen + ":"\
		+ str(fitness) + ":"\
		+ str(dist_esq) + ":"\
		+ str(dist_dir) + ":"\
		+ str(dist_cima) + ":"\
		+ str(dist_baixo) + ":"\
		+ str(vivo)

	get_node("/root/Mundo").notificar(msg)
	# fitness = 0
	get_node("/root/Mundo").show_fitness(fitness)

func mover(mov):
	if mov == "md":
		global_position.x += 5
	elif mov == "me":
		global_position.x -= 5
	elif mov == "mc":
		global_position.y -= 5
	elif mov == "mb":
		global_position.y += 5
	elif mov == "at":
		shoot_laser()
		pass
		

func _on_TimeSensores_timeout():
	var dist0 = 500
	var dist1 = 500
	var dist2 = 500
	var sensorAnt = sensor
	if(obj_enemies[0] != null and weakref(obj_enemies[0]).get_ref()):
		dist0 = global_position.distance_to(obj_enemies[0].get_position())
	if(obj_enemies[1] != null and weakref(obj_enemies[1]).get_ref()):
		if obj_enemies[1].get_position().y <= global_position.y: 
			dist1 = global_position.distance_to(obj_enemies[1].get_position())
	if(obj_enemies[2] != null and weakref(obj_enemies[2]).get_ref()):
		dist2 = global_position.distance_to(obj_enemies[2].get_position())
	sensor = [dist0, dist1, dist2]
	
	#if dist0 < 80:
	#	obj_enemies[0].take_damage(1)
	#	take_damage(1)
	#if dist1 < 80:
	#	obj_enemies[1].take_damage(1)
	#	take_damage(1)	
	#if dist2 < 80:
	#	obj_enemies[2].take_damage(1)
	#	take_damage(1)
			
	#fitness += 0.01
	
	#if dist_baixo < 40 or dist_cima < 40 or dist_esq < 40 or dist_dir < 40:
	#	fitness -=0.5
	
	notificar_dados()
	fitness = 0 if fitness < 0 else fitness

	obj_enemies[0] = obj_enemies[0] if dist0 < 300 else null
	obj_enemies[1] = obj_enemies[1] if dist1 < 300 else null
	obj_enemies[2] = obj_enemies[2] if dist2 < 300 else null

func set_id(id):
	id_ind = id
	
func get_id():
	return id_ind


func _on_TimerRecargaBalas_timeout():
	#if quant_balas == 0:
	#	fitness -= 10
	if quant_balas < 50:
		quant_balas += 1
	
