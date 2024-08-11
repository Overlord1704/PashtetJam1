extends Node2D

@export var player : CharacterBody2D

var is_taked : bool # Подобрана?
var is_placed : bool # Пололжил ли?

var body_pipe : _TakeObject
var place : _PlaceObject

func _ready():
	player.take_object.connect(Take)
	player.place_object.connect(Place)
	player.quit_game.connect(QuitGame)

func _physics_process(delta):
	if is_taked:
		body_pipe.position = player.position
	if is_placed:
		body_pipe.position = place.position

func Take(body : _TakeObject):
	if !body_pipe:
		is_taked = true
		body_pipe = body

func Place(zone_place : _PlaceObject):
	if body_pipe:
		is_placed = true
		place = zone_place
		is_taked = false

func QuitGame():
	get_tree().change_scene_to_file("res://scenes/StartMenu/start_menu.tscn")
