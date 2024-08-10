extends CharacterBody2D

signal take_object
signal place_object
signal quit_game

@export var VelocityComponent : _VelocityComponent

var MousePosition : Vector2
<<<<<<< HEAD
func _ready():
	$CanvasLayer/GameTimer.game_over.connect(GameOver)
=======

func _ready():
	$CanvasLayer/GameTimer.game_over.connect(GameOver)
	
>>>>>>> aefe056ae983134dbb327d5c5abc0c09d7595bf5
func _input(event):
	### Отвечает за поворот персонажа ###
	MousePosition = get_global_mouse_position()
	look_at(MousePosition)

func _physics_process(delta):
	VelocityComponent.Move(self) # Перс двигается

func GameOver():
	quit_game.emit()
