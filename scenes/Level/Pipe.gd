extends Node2D
class_name _TakeObject

var active : bool


var type: String = ''
var code: String = ''

func _physics_process(delta):
	$Area2D/CollisionShape2D.disabled = active
	print($Area2D/CollisionShape2D.disabled)
