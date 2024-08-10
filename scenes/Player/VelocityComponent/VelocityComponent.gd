extends Node
class_name _VelocityComponent

###	Вынес передвижение персонажа в отдельный компонент. Он получает transform,и меняет velocity игрока ###

@export var speed = 100

var Velocity : Vector2
var Transform : Transform2D

var ACCELERATION = 0.1 # Как быстро он ускоряется
var BORDER := 80 # Границы, за которые velocity не может выйти

var is_accel : bool # Ускоряется на ПКМ?
var is_friction : bool # Замедляется? 

func _physics_process(delta):
	Velocity += Transform.x * speed*ACCELERATION
	Velocity.x = clamp(Velocity.x,-BORDER,BORDER)
	Velocity.y = clamp(Velocity.y,-BORDER,BORDER)
	
	if is_accel:
		Acceleration()
	elif is_friction:
		Friction()
	#print(Velocity)

func Acceleration():
	BORDER = 250

func Friction():
	if BORDER != 80: # Плавное замедление персонажа
		BORDER -= 2
	else:
		is_friction = false

func Move(player : CharacterBody2D):
	player.velocity = Velocity
	Transform = player.transform
	player.move_and_slide()
