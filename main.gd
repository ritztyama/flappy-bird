extends Node

@export var pipe_scene : PackedScene
var game_running : bool
var game_over : bool
var scroll
var score
const SCROLL_SPEED : int = 4
var screen_size :Vector2i
var ground_height : int
var pipes : Array
const PIPE_DELAY : int = 100
const PIPE_RANGE : int = 200

# Called when the node enters the scene tree for the first time.
func _ready():
	$BestScore.hide()
	$ScoreLabel.hide()
	screen_size = get_window().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	$GameOver.hide()
	$start.show()
	$ColorRect.show()

func new_game():
	#reset variables
	$BestScore.show()
	$ScoreLabel.show()
	game_running = false
	game_over = false
	score = 0
	scroll = 0
	$ScoreLabel.text = "SCORE: " + str(score)
	get_tree().call_group("pipes","queue_free")
	pipes.clear()
	gecerate_pipes()
	$Bird.reset()
	$start.hide()

func _input(event):
	if game_over == true:
		return
		
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if game_running == true:
				if $Bird.flying:
					$Bird.flap()
					check_top()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func start_game():
	game_running = true
	$Bird.flying = true
	$Bird.flap()
	$PipeTimer.start()

func _process(delta):
	if game_running:
		scroll += SCROLL_SPEED
		#reset scroll
		if  scroll >= screen_size.x:
			scroll = 0
		#move ground node
		$Ground.position.x = -scroll
		for pipe in pipes:
			pipe.position.x -= SCROLL_SPEED

func _on_pipe_timer_timeout():
	gecerate_pipes()

func gecerate_pipes():
	var pipe = pipe_scene.instantiate()
	pipe.position.x = screen_size.x + PIPE_DELAY
	pipe.position.y = (screen_size.y - ground_height) / 2 + randi_range(-PIPE_RANGE, PIPE_RANGE)
	pipe.hit.connect(bird_hit)
	pipe.scored.connect(scored)
	add_child(pipe)
	pipes.append(pipe)

func scored():
	score += 1
	$ScoreLabel.text = "SCORE: " + str(score) 

func check_top():
	if $Bird.position.y< 0:
		$Bird.falling = true
		stop_game()

func stop_game():
	$PipeTimer.stop()
	$ColorRect.show()
	if int($ScoreLabel.text) > int($BestScore.text):
		$BestScore.text = $ScoreLabel.text
	$Bird.flying = false
	game_running = false
	game_over = true

func bird_hit():
	$GameOver.show()
	$Bird.falling = true
	stop_game()

func _on_ground_hit():
	$GameOver.show()
	$Bird.falling = false
	stop_game()

func _on_game_over_restart():
	$GameOver.hide()
	$start.show()

func _on_start_start():
	$GameOver.hide()
	$ColorRect.hide()
	new_game()
	start_game()
