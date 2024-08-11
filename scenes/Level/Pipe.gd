extends Node2D
class_name _TakeObject

var active : bool


func _physics_process(delta):
	$Area2D/CollisionShape2D.disabled = active
	print($Area2D/CollisionShape2D.disabled)
