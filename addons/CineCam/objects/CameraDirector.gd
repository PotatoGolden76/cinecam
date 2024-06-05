@tool
@icon("res://addons/CineCam/assets/gizmos/CameraDirector.svg")
extends Node3D
class_name CameraDirector
## Manages the global camera of a scene and
## handles transitions between [VirtualCamera]s

## Name of the initial [VirtualCamera]
@export var initial_camera: String = ""
## Dictionary of type [String] -> [VirtualCamera], where the key is the name of the camera
var cameras: Dictionary
## Reference to the global [Camera3D] child
var _global_camera: Camera3D
## The currently active [VirtualCamera]
var _current_camera: Camera3D = null

## Whether there is an ongoing transition or not
var is_transitioning: bool = false
## Current ongoing [Transition]
var _current_transition: Transition
signal transition_started(from: String, to: String)
signal transition_ended

## Elapsed time sicne the start of the transition, from 0 to [member Transition.duration]
var time: float = 0
## The global camera position when a transition is started
var _initial_pos: Vector3
## The global camera rotation when a transition is started
var _initial_rot: Vector3
## The global camera FOV when a transition is started
var _initial_fov: float

## The [TransitionDictionary] used by this CameraDirector
@export var transitions: TransitionDictionary:
	set(value):
		# Connect to dictionary updates for the purpose of saving the resource properly
		if transitions:
			transitions.transition_added.disconnect(_save_transition_dict)
			transitions.transition_updated.disconnect(_save_transition_dict)
			transitions.transition_removed.disconnect(_save_transition_dict)

		transitions = value

		if transitions:
			transitions.transition_added.connect(_save_transition_dict)
			transitions.transition_updated.connect(_save_transition_dict)
			transitions.transition_removed.connect(_save_transition_dict)

		# Update the new resource's camera list
		update_cameras()

func _ready():
	if transitions:
		transitions = ResourceLoader.load(transitions.resource_path)
	if is_inside_tree():
		# Populate the [TransitionDictionary]'s camera list at startup
		update_cameras()
		# Connect to [SceneTree] changes to detect [VirtualCamera]'s being added/renamed/removed
		get_tree().node_added.connect(_camera_added)
		get_tree().node_renamed.connect(_camera_renamed)
		get_tree().node_removed.connect(_camera_removed)

		# Set the global [Camera3D] as the current one
		if _global_camera:
			_global_camera.current = true
		else:
			for child in get_children():
				if child is Camera3D:
					_global_camera = child
					_global_camera.current = true
		
		# Set the first [VirtualCamera] as current on startup
		if len(cameras) > 0:
			if cameras.has(initial_camera):
				_current_camera = cameras[initial_camera]
			else:
				push_warning("Initial camera not found")
				_current_camera = cameras[cameras.keys()[0]]
			_current_camera.activate_camera()
		else:
			push_warning("No VirtualCameras found in the scene")

func _camera_added(node: Node) -> void:
	if node is VirtualCamera:
		update_cameras()
		# Set the new camera as current if there isn't already one
		if len(cameras) > 0 and not _current_camera:
			if cameras.has(initial_camera):
				_current_camera = cameras[initial_camera]
			else:
				_current_camera = cameras[cameras.keys()[0]]
			_current_camera.activate_camera()

func _camera_renamed(node: Node) -> void:
	if node is VirtualCamera:
		update_cameras()

func _camera_removed(node: Node) -> void:
	if node is VirtualCamera and is_inside_tree():
		update_cameras()
		# If the current camera is removed, set the current camera as the next one or null
		if len(cameras) > 0 and _current_camera.name == node.name:
			if cameras.has(initial_camera):
				_current_camera = cameras[initial_camera]
			else:
				_current_camera = cameras[cameras.keys()[0]]
			_current_camera.activate_camera()
		if len(cameras) == 0:
			_current_camera = null
			push_warning("No VirtualCameras found in the scene")

## Update the list of [VirtualCamera]s
func update_cameras() -> void:
	if is_inside_tree():
		cameras.clear()
		# Update the internal camera list
		for cam in get_tree().get_nodes_in_group("VirtualCameras"):
			cameras[cam.name] = cam
			
		if transitions:
			# Update the camera list of the current [TransitionDictionary]
			transitions.update_cameras(cameras.keys())

## Change the currently active camera.
## The plugin handles cameras using their string name, please ensure that
## even if they are not on the same level, all [VirtualCamera]s have unique names.
## In case of temporarily having the same name for two cameras and the camera list not
## updating anymore, just close and reopen the scene
func change_camera(to: String) -> void:
	if cameras[to]:
		transition_started.emit(_current_camera.name, to)
		is_transitioning = true
		_current_transition = transitions.get_transition_or_default(_current_camera.name, to)

		time = 0
		_initial_pos = _global_camera.global_position
		_initial_rot = _global_camera.global_rotation
		_initial_fov = _global_camera.fov

		# _current_camera gets changed in the beginning of the transition
		_current_camera.deactivate_camera()
		_current_camera = cameras[to]
		_current_camera.activate_camera()
	else:
		push_error("Camera %s does not exist" % to)

func _physics_process(delta):
	if _global_camera and _current_camera and is_inside_tree():
		if not is_transitioning:
			# Keep global camera properties the same as the current [VirtualCamera]
			_global_camera.global_position = _current_camera.global_position
			_global_camera.global_rotation = _current_camera.global_rotation
			_global_camera.fov = _current_camera.fov
		else:
			# Handle the ongoing transition
			_do_transition(delta)

func _do_transition(delta: float) -> void:
	if not _current_camera:
		push_error("No active VirtualCamera")
		is_transitioning = false
		transition_ended.emit()
		return
	if not _current_transition:
		push_error("No active transition")
		is_transitioning = false
		transition_ended.emit()
		return
	match _current_transition.mode:
		CineCamConstants.TransitionModes.CUT:
			is_transitioning = false
			transition_ended.emit()
		CineCamConstants.TransitionModes.EASED:
			time += delta
			var local_time = time / _current_transition.duration
			match _current_transition.easing_function:
				CineCamConstants.EasingModes.LINEAR:
					if _current_transition.properties&CineCamConstants.TransitionProperties.POSITION:
						_global_camera.global_position = EasingFunctions.Linear(_initial_pos, _current_camera.global_position, local_time)
					if _current_transition.properties&CineCamConstants.TransitionProperties.ROTATION:
						_global_camera.global_rotation = EasingFunctions.Linear(_initial_rot, _current_camera.global_rotation, local_time)
					if _current_transition.properties&CineCamConstants.TransitionProperties.FOV:
						_global_camera.fov = EasingFunctions.Linear(_initial_fov, _current_camera.fov, local_time)
				CineCamConstants.EasingModes.EASE_IN:
					if _current_transition.properties&CineCamConstants.TransitionProperties.POSITION:
						_global_camera.global_position = EasingFunctions.EaseIn(_initial_pos, _current_camera.global_position, local_time)
					if _current_transition.properties&CineCamConstants.TransitionProperties.ROTATION:
						_global_camera.global_rotation = EasingFunctions.EaseIn(_initial_rot, _current_camera.global_rotation, local_time)
					if _current_transition.properties&CineCamConstants.TransitionProperties.FOV:
						_global_camera.fov = EasingFunctions.EaseIn(_initial_fov, _current_camera.fov, local_time)
				CineCamConstants.EasingModes.EASE_OUT:
					if _current_transition.properties&CineCamConstants.TransitionProperties.POSITION:
						_global_camera.global_position = EasingFunctions.EaseOut(_initial_pos, _current_camera.global_position, local_time)
					if _current_transition.properties&CineCamConstants.TransitionProperties.ROTATION:
						_global_camera.global_rotation = EasingFunctions.EaseOut(_initial_rot, _current_camera.global_rotation, local_time)
					if _current_transition.properties&CineCamConstants.TransitionProperties.FOV:
						_global_camera.fov = EasingFunctions.EaseOut(_initial_fov, _current_camera.fov, local_time)
				CineCamConstants.EasingModes.EASE_IN_OUT:
					if _current_transition.properties&CineCamConstants.TransitionProperties.POSITION:
						_global_camera.global_position = EasingFunctions.EaseInOut(_initial_pos, _current_camera.global_position, local_time)
					if _current_transition.properties&CineCamConstants.TransitionProperties.ROTATION:
						_global_camera.global_rotation = EasingFunctions.EaseInOut(_initial_rot, _current_camera.global_rotation, local_time)
					if _current_transition.properties&CineCamConstants.TransitionProperties.FOV:
						_global_camera.fov = EasingFunctions.EaseInOut(_initial_fov, _current_camera.fov, local_time)
			
			if time >= _current_transition.duration:
				is_transitioning = false
				transition_ended.emit()

# Save the [TransitionDictionary] resource on changes
func _save_transition_dict() -> void:
	# Only save in the editor. `res://` is read-only at runtime
	if not Engine.is_editor_hint():
		return
	# Do not allow built-in resources as ResourceSaver can't save with no path
	if not transitions.resource_path or transitions.resource_path == "":
		push_error("Failed to save TransitionDictionary, invalid resource path.")
		return
	var err = ResourceSaver.save(transitions)
	if err != OK:
		push_error("Failed to save TransitionDictionary: %s" % err)

# Ensure that the Camera Director has a Camera3D child to use as global camera
func _get_configuration_warnings() -> PackedStringArray:
	var warnings = []
	var found = false
	for child in get_children():
		if child is Camera3D:
			_global_camera = child
			found = true
			break
	if not found:
		warnings.append("CameraDirector should have a [Camera3D] child.")
	return warnings
