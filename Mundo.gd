extends Node2D

const PORT = 9080
var _server = WebSocketServer.new()

var PlayerNovo = preload("res://characters/player/PlayerNovo.tscn")

var id_client = -1
var players = []
var geracao = -1
var prox_coluna = null


func criar_player(id):
	var p = PlayerNovo.instance()
	p.global_position = Vector2(270,750)
	p.set_id(id)
	players.append(p)
	add_child(p)

func mover_player(id, mov):
	if(players[id] != null and weakref(players[id]).get_ref()):
		players[id].mover(mov)
	
func pontos_player(id, pontos):
	if(len(players) > id  and players[id] != null and weakref(players[id]).get_ref()):
		players[id].fitness += pontos
		players[id].enemies_dead_per_time += 1
		
func pontos_vivos():
	for player in players:
		if player != null and weakref(player).get_ref()  and player.vivo:
			player.fitness += 10
			pass

func _physics_process(delta):
	$Label.text = "IA DESCONECTADA" if id_client == -1 else "Geracao: " + str(geracao)
## WebSocket 
func _ready():
	#Engine.time_scale = 10
	$Label2.text = "FITNESS: "
	#criar_player(0)
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
	id_client = id
	geracao = -1

func _close_request(id, code, reason):
	print("Client %d disconnecting with code: %d, reason: %s" % [id, code, reason])
	id_client = -1

func _disconnected(id, was_clean = false):
	print("Client %d disconnected, clean: %s" % [id, str(was_clean)])
	id_client = -1

func _on_data(id):
	var pkt = _server.get_peer(id).get_packet()
	var msg = pkt.get_string_from_utf8()
	# print("Client %d: %s" % [id, msg])
	
	if "create" in msg:
		var el_id = int(msg.split(":")[1])
		$EnemySpawner.kill_all()
		$EnemySpawner.speed = 150
		$EnemySpawner.wait_time = 4
		criar_player(el_id)
	elif "restart" in msg:
		geracao += 1
		restart_all()
		players = []
		
	else:
		var id_player = int(msg.split(":")[0])
		var mov = msg.split(":")[1]
		mover_player(id_player, mov)
	#_server.get_peer(id).put_packet(pkt)

func restart_all():
	for player in players:
			if(player != null and weakref(player).get_ref()):
				player.free()
	players = []
	$EnemySpawner.kill_all()
	$EnemySpawner.speed = 150
	$EnemySpawner.wait_time = 1
	

func _process(delta):
	_server.poll()
	
func notificar(msg):
	if id_client != -1:
		_server.get_peer(id_client).put_packet(msg.to_utf8())
	else:
		print(msg)
		pass

func show_fitness(valor):
	$Label2.text = "Fitness: " + str(valor)

func _on_Timer_timeout():
	var player_menor = null
	for player in players:
		if player != null and weakref(player).get_ref() and player.fitness < player_menor.fitness and player.vivo:
			#var msg  = player.get_id() + ":" + player.get_position() + ":" + player.
			#notificar()
			pass
	if player_menor != null and weakref(player_menor).get_ref():
		player_menor.take_damage(3)
