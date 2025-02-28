extends Node

@export var snake_scene : PackedScene

var score : int
var inicio : bool = false
var numero : int

var celda : int = 20
var cell_size : int = 50


var posicion_fruta : Vector2
var regen_food : bool = true
var posicionNumero : Vector2

var old_data : Array
var snake_data : Array
var snake : Array

#movimiento variables
var start_pos = Vector2(9, 9)
var up = Vector2(0, -1)
var down = Vector2(0, 1)
var left = Vector2(-1, 0)
var right = Vector2(1, 0)
var direccion : Vector2
var mover: bool

func _ready():
	new_game()
	
	
func new_game():
	get_tree().paused = false
	get_tree().call_group("segments", "queue_free")
	$GameOverMenu.hide()
	score = 0
	$Hud.get_node("ScoreLabel").text = "SCORE: " + str(score)
	direccion = up
	mover = true
	generate_snake()
	move_food()
	1
	
func generate_snake():
	old_data.clear()
	snake_data.clear()
	snake.clear()
	for i in range(3):
		add_segment(start_pos + Vector2(0, i))
		
func add_segment(pos):
	snake_data.append(pos)
	var SnakeSegment = snake_scene.instantiate()
	SnakeSegment.position = (pos * cell_size) + Vector2(0, cell_size)
	add_child(SnakeSegment)
	snake.append(SnakeSegment)
	
func _process(delta):
	move_snake()
	
func move_snake():
	if mover:
		if Input.is_action_just_pressed("move_down") and direccion != up:
			direccion = down
			mover = false # Impide que la serpiente se mueva más de una vez por frame
			if not inicio:
				start_game()
		if Input.is_action_just_pressed("move_up") and direccion != down:
			direccion = up
			mover = false # Impide que la serpiente se mueva más de una vez por frame
			if not inicio:
				start_game()
		if Input.is_action_just_pressed("move_left") and direccion != right:
			direccion = left
			mover = false
			if not inicio:
				start_game()
		if Input.is_action_just_pressed("move_right") and direccion != left:
			direccion = right
			mover = false
			if not inicio:
				start_game()

func start_game():
	inicio = true
	$MoveTimer.start()
	# $MoveTimer.wait_time = 0.1  # Aumenta la velocida

func _on_move_timer_timeout():
	mover = true
	$Numero.text = str(randi_range(1 ,9))
	old_data = [] + snake_data
	snake_data[0] += direccion # Mueve la cabeza de la serpiente según la dirección
	for i in range(len(snake_data)):
		if i > 0:
			snake_data[i] = old_data[i - 1]  # Desplaza cada segmento hacia la posición anterior
		snake[i].position = (snake_data[i] * cell_size) + Vector2(0, cell_size)
	check_out_of_bounds() # Verifica si la serpiente ha salido de los límites
	check_self_eaten() # Verifica si la serpiente se ha mordido a sí misma
	check_food_eaten()
	
func check_out_of_bounds():
	if snake_data[0].x < 0 or snake_data[0].x > celda - 1 or snake_data[0].y < 0 or snake_data[0].y > celda - 1:
		end_game()
		
func check_self_eaten():
	for i in range(1, len(snake_data)):
		if snake_data[0] == snake_data[i]:  # Si la cabeza está en la misma posición que otro segmento
			end_game()
			
func check_food_eaten():
	if snake_data[0] == posicion_fruta:
		score += 1
		$Hud.get_node("ScoreLabel").text = "SCORE: " + str(score)
		$Hud.getç
		add_segment(old_data[-1])
		
		move_food()
	
func move_food():
	while regen_food:
		regen_food = false
		posicion_fruta = Vector2(randi_range(0, celda - 1), randi_range(0, celda - 1))
		for i in snake_data:
			if posicion_fruta == i:
				regen_food = true
	$Food.position = (posicion_fruta * cell_size)+ Vector2(0, cell_size)
	regen_food = true
	
	# $MoveTimer.wait_time = max(0.05, $MoveTimer.wait_time * 0.95)  # Reduce el tiempo de esper

func end_game():
	$GameOverMenu.show()
	$MoveTimer.stop()
	inicio = false
	get_tree().paused = true


func _on_game_over_menu_restart():
	new_game()
