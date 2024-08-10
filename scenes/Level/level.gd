extends Node2D

@export var player : CharacterBody2D

func _ready():
	player.take_object.connect(Take)
	player.place_object.connect(Place)
	player.quit_game.connect(QuitGame)
	
func Take():
	print("take")

func Place():
	print("place")

func QuitGame():
	get_tree().change_scene_to_file("res://scenes/StartMenu/start_menu.tscn")
