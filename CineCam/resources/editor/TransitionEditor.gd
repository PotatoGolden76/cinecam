@tool
extends Control
class_name TransitionEditor
## Custom editor window for [TransitionDictionary] editing

const _camera_button_scene = preload ("res://addons/CineCam/resources/editor/CameraButton.tscn")
const _transition_button_scene = preload ("res://addons/CineCam/resources/editor/TransitionButton.tscn")

@onready var _camera_list = $MainWindow/CameraList/List/ScrollContainer/Cameras
@onready var _transition_list = $MainWindow/TransitionList/List/ScrollContainer/Transitions

@onready var _add_transition_button = $MainWindow/TransitionList/List/Toolbar/Wrapper/AddTransition
@onready var _selected_camera_label = $MainWindow/TransitionList/List/Toolbar/Wrapper/CurrentCam

var _current_camera: String = ""
var _current_resource: TransitionDictionary:
	set(value):
		_current_resource = value
		_set_camera_list()

func _ready():
	_clear_camera_list()
	_clear_transition_list()

	_add_transition_button.button_up.connect(_add_transition)

## Set what resource the editor should handle
func set_current_resource(res: TransitionDictionary):
	if _current_resource:
		_current_resource.cameras_updated.disconnect(_set_camera_list)
	_current_resource = res
	_current_resource.cameras_updated.connect(_set_camera_list)
	_set_camera_list()

## Get the current resource being edited
func get_current_resource():
	return _current_resource

func _clear_camera_list() -> void:
	for c in _camera_list.get_children():
		c.queue_free()

func _clear_transition_list() -> void:
	for c in _transition_list.get_children():
		c.queue_free()

func _set_camera_list() -> void:
	_current_camera = ""
	_clear_transition_list()
	_clear_camera_list()

	for c in _current_resource.get_cameras():
		var instance = _camera_button_scene.instantiate()
		instance.get_child(0).text = c
		instance.get_child(0).pressed.connect(_camera_selected.bind(c))
		_camera_list.add_child(instance)

func _set_transition_list() -> void:
	_clear_transition_list()
	_selected_camera_label.text = _current_camera
	if _current_resource:
		var cams = _current_resource.get_cameras()
		if _current_camera != "" and len(cams) > 1:
			for t in _current_resource.get_transitions(_current_camera):
				var instance = _transition_button_scene.instantiate()
				_transition_list.add_child(instance)
				instance.set_transition(t, _current_camera)
				instance.set_cameras(cams)
				instance.remove.connect(_remove_transition)
				instance.updated.connect(_update_transition)

func _add_transition():
	if _current_resource:
		var cams = _current_resource.get_cameras()
		if _current_camera != "" and len(cams) > 1:
			for c in cams:
				if c != _current_camera:
					var trans = Transition.get_default(c)
					_current_resource.add_transition(_current_camera, trans)
					_set_transition_list()
					break

func _remove_transition(trans: Transition):
	if _current_resource and _current_camera != "":
		_current_resource.remove_transition(_current_camera, trans)
		_set_transition_list()

func _camera_selected(cam: String):
	_current_camera = cam
	_set_transition_list()

func _update_transition():
	_current_resource.update_transition()

func _exit_tree():
	if _current_resource:
		_current_resource.cameras_updated.disconnect(_set_camera_list)