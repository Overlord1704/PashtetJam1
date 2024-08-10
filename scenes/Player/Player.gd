extends CharacterBody2D

signal take_object
signal place_object

@export var VelocityComponent : _VelocityComponent

var MousePosition : Vector2

func _input(event):
	### Отвечает за поворот персонажа ###
	MousePosition = get_global_mouse_position()
	look_at(MousePosition)
	
func _physics_process(delta):
	VelocityComponent.Move(self) # Перс двигается

