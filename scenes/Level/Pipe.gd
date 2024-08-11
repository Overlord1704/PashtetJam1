extends Node2D
class_name _TakeObject

@export var active : bool

func _physics_process(delta):
	$Area2D.monitorable = active
