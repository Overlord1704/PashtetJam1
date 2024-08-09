extends Node
class_name _VelocityComponent

###	Вынес передвижение персонажа в отдельный компонент. Он получает transform,и меняет velocity игрока ###

@export var speed = 400

var Velocity : Vector2
var Transform : Transform2D
var Direction : Vector2

var ACCELERATION = 100
var FRICTION = 50

var is_accel : bool
var is_friction : bool

func _physics_process(delta):
	Velocity = Transform.x * speed
	if is_accel:
		Accelerate()
	elif is_friction:
		Friction()
	print(Velocity.x)

func Accelerate():
	Velocity = Velocity.move_toward(speed*Velocity,ACCELERATION)

func Friction():
	Velocity = Velocity.move_toward(Vector2.ZERO,FRICTION)

func Move(player : CharacterBody2D):
	player.velocity = Velocity
	Transform = player.transform
	player.move_and_slide()
