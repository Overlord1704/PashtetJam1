extends Node2D
class_name _GameTimer

signal game_over

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$ProgressBar.value -= $ProgressBar.step
	print($ProgressBar.value)
	if $ProgressBar.value == 0:
		game_over.emit()
