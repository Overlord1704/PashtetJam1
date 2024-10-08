extends CharacterBody2D
#class_name Player

signal take_object
signal place_object
signal quit_game

@export var VelocityComponent : _VelocityComponent
@export var SoundMovement : AudioStreamPlayer2D

@onready var marker = $Marker2D

var MousePosition : Vector2

func _ready():
	$CanvasLayer/GameTimer.game_over.connect(GameOver)
	SoundMovement.play(0)

func _input(event):
	### Отвечает за поворот персонажа ###
	MousePosition = get_global_mouse_position()
	look_at(MousePosition)

func _physics_process(delta):
	VelocityComponent.Move(self) # Перс двигается

func GameOver():
	quit_game.emit()
