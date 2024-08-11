extends Node2D
class_name _TakeAndPlaceComponent

var player : CharacterBody2D

func _ready():
	# Проверка на то, является ли компонент дочерним узлом игрока
	if get_parent() is CharacterBody2D:
		player = get_parent()
	else:
		print("Parent is not CharacterBody2D")

func _on_area_2d_body_entered(body):
	if body is _TakeObject:
		player.take_object.emit(body)

func _on_area_2d_area_entered(area):
	if area is _PlaceObject:
		player.place_object.emit(area)
