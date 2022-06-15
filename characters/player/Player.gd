extends Area2D
class_name Player

const PORT = 9080
var _server = WebSocketServer.new()



signal spawn_laser(location)

onready var muzzle = $Muzzle

var speed = 300

var input_vector = Vector2.ZERO

var hp = 3

func _physics_process(delta):
	input_vector.x = Input.get_action_strength("mover_direita") - Input.get_action_strength("mover_esquerda")
	input_vector.y = Input.get_action_strength("mover_baixo") - Input.get_action_strength("mover_cima")
	
	global_position += input_vector * speed * delta
	
	if Input.is_action_just_pressed("atirar"):
		shoot_laser()
	
	
func take_damage(damage):
	hp -= damage
	if hp <= 0:
		queue_free()


func _on_Player_area_entered(area):
	if area.is_in_group("enemies"):
		area.take_damage(1)

func shoot_laser():
	emit_signal("spawn_laser", muzzle.global_position)
	

# Servidor WS #
func _ready():
	_server.connect("client_connected", self, "_connected")
	_server.connect("client_disconnected", self, "_disconnected")
	_server.connect("client_close_request", self, "_close_request")
	_server.connect("data_received", self, "_on_data")
	var err = _server.listen(PORT)
	if err != OK:
		print("Unable to start server")
		set_process(false)
	else:
		print("Serve started")

func _connected(id, proto):
	print("Client %d connected with protocol: %s" % [id, proto])

func _close_request(id, code, reason):
	print("Client %d disconnecting with code: %d, reason: %s" % [id, code, reason])

func _disconnected(id, was_clean = false):
	print("Client %d disconnected, clean: %s" % [id, str(was_clean)])

func _on_data(id):
	var pkt = _server.get_peer(id).get_packet()
	var msg = pkt.get_string_from_utf8()
	print("Client %d: %s" % [id, msg])
	if msg == "mover_direita":
		global_position.x += 1
	elif msg == "mover_esquerda":
		global_position.x -= 1
	elif msg == "mover_cima":
		global_position.y -= 1
	elif msg == "mover_baixo":
		global_position.y += 1
	elif msg == "atirar":
		shoot_laser()
		
	_server.get_peer(id).put_packet(pkt)

func _process(delta):
	_server.poll()
