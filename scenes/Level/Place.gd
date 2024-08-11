extends Area2D
class_name _PlaceObject

var type: String = ''
var code: String = ''

var _sprite

func set_sprite(sprite):
	_sprite = sprite
	add_child(_sprite)

func get_sprite():
	return _sprite

func check(other: String):
	return other == type

func install_pipe(pipe: _TakeObject):
	if pipe.type == type and not _sprite.visible:
		_sprite.show()
		return true
	else:
		return false
