extends Area2D


# Declare member variables here. Examples:
# var a = 2
var speed = 150
var passou = false

func _physics_process(delta):
	global_position.y += speed * delta
	
	if global_position.y > 750 and not passou:
			get_node("/root/Mundo").pontos_vivos()
			get_node("/root/Mundo/EnemySpawner").atualizar_prox_col()
			passou = true
			

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func take_damage():
	queue_free()

func _on_EnemyCol_area_entered(area):
	if area is PlayerNovo:
		area.take_damage(1)


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
	pass # Replace with function body.
