extends Node

func _ready():$AnimationPlayer.play("animate")

var current = 0
func _process(delta):
	var cams = $CameraDirector.cameras.keys()

	if Input.is_action_just_pressed("ui_up"):
		current += 1
		if current == len(cams):
			current = 0
		$CameraDirector.change_camera(cams[current])

	if Input.is_action_just_pressed("ui_down"):
		current -= 1
		if current < 0:
			current = len(cams)-1
		$CameraDirector.change_camera(cams[current])
