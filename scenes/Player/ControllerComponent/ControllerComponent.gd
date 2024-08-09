extends Node2D
class_name _ControllerComponent

@export var VelocityComponent : _VelocityComponent

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			VelocityComponent.is_accel = true
			VelocityComponent.is_friction = false
		elif event.button_index == MOUSE_BUTTON_RIGHT and !event.pressed:
			VelocityComponent.is_accel = false
			VelocityComponent.is_friction = true
