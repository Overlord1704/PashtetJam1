extends Node2D


@export var player : CharacterBody2D

var is_taked : bool # Подобрана?
var is_placed : bool # Пололжил ли?

var body_pipe : _TakeObject
var place : _PlaceObject

@export var Fragments : int
var current_fragments := 0

func _ready():
	player.take_object.connect(Take)
	player.place_object.connect(Place)
	player.quit_game.connect(QuitGame)

func _physics_process(delta):
	if is_taked:
		body_pipe.global_position = player.marker.global_position
		#lerp(body_pipe.global_position, player.marker.global_position, delta)
	if is_placed and body_pipe != null:
		$PlacePipe.play(0)
		body_pipe.global_position = place.global_position
		current_fragments += 1
	
	if current_fragments >= Fragments:# Победное меню
		get_tree().change_scene_to_file("res://scenes/WinnerMenu/winner.tscn")
		
func Take(body : _TakeObject):
	if is_taked:
		return
	$TakePipe.play(0)
	is_taked = true
	body_pipe = body
	is_placed = false

func Place(zone_place : _PlaceObject):
	if is_taked and zone_place.install_pipe(body_pipe):
		is_placed = true
		place = zone_place
		is_taked = false
		body_pipe.queue_free()

func QuitGame():
	get_tree().change_scene_to_file("res://scenes/StartMenu/start_menu.tscn")
