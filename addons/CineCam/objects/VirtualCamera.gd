@tool
@icon("res://addons/CineCam/assets/gizmos/VirtualCamera.svg")
extends Camera3D
class_name VirtualCamera
## A configurable cinematic camera.
##
## The VirtualCamera node is a configurable camera with multiple options
## for following and looking at at a target.


signal camera_activated
signal camera_deactivated
## Signal emited when FollowMode = [i]PATH_FOLLOW[/i].
## Signals that the camera has reached the end of the path
signal track_ended


## How the VirtualCamera should position itself in relation to a target
@export var follow_mode: CineCamConstants.FollowModes:
	set(value):
		should_lock_position = false
		follow_mode = value
		notify_property_list_changed()

## How the VirtualCamera should rotate itself in relation to a target
@export var aim_mode: CineCamConstants.AimModes:
	set(value):
		should_lock_aim = false
		aim_mode = value
		notify_property_list_changed()

## Whether this camera is the currently active one
var is_active: bool = false
## Whether to update camera position and rotation in the editor
@export var update_in_editor: bool = true
## Whether to update camera position and rotation when inactive
@export var update_when_inactive: bool = true
## Whether camera position should be set to the
## follow target's position when [i]_ready()[/i]
## is called.
## [br][b]NOTE:[/b] does nothing if FollowMode is [i]static[/i]
@export var reset_on_ready: bool = false
## Whether camera position should be set to the
## follow target's position when activated.
## [br][b]NOTE:[/b] does nothing if FollowMode is [i]static[/i]
@export var reset_on_activate: bool = true

## Target for camera tracking
var follow_target: Node3D
## Target for camera aim
var aim_target: Node3D

## Lock camera position. Acts like FollowModes.STATIC
var should_lock_position: bool = false
## Lock camera rotation. Acts like AimModes.STATIC
var should_lock_aim: bool = false

## Speed used by follow modes
var follow_speed = 0.3
## Offset from the target, used by follow modes
var target_offset: Vector3 = Vector3.ZERO
## [Path3D] used by FollowModes.PATH_FOLLOW
var tracking_path: Path3D
## Offset from the start of the [Path3D] used by FollowModes.PATH_FOLLOW.
## For more information see [method Curve3D.samplef]
var path_offset: float = 0
## Whether to move along the [Path3D] used by FollowModes.PATH_FOLLOW at given speed.
var move_along: bool = true
## Whether to loop when the end of the [Path3D] used by FollowModes.PATH_FOLLOW is reached.
## This moves the camera to the beginning of the path
var path_loop: bool = false
## Is FollowModes.FOLLOW dampened
var is_dampened: bool = false
## Wether offset should be rotated with the target in FollowModes.FOLLOW
var rotate_with_target: bool = false

func _init():
	# Ensure that all [VirtualCamera]s are in the proper group
	add_to_group("VirtualCameras")

func _exit_tree():
	remove_from_group("VirtualCameras")

func _ready():
	# Make all [VirtualCamera]s not current, so they don't take over
	# the global camera
	if is_inside_tree():
		current = false

		if reset_on_ready:
			reset_camera()

## Activate this camera
func activate_camera():
	is_active = true
	if reset_on_activate:
		reset_camera()
	camera_activated.emit()

## Deactivate this camera
func deactivate_camera():
	is_active = false
	camera_deactivated.emit()

## Sets camera position to the target's position if [i]FollowMode[/i] is [b]NOT[/b] static
## and [i]follow_target[/i] is valid
func reset_camera():
	if follow_mode != CineCamConstants.FollowModes.STATIC and follow_mode != CineCamConstants.FollowModes.PATH_FOLLOW:
		if follow_target:
			global_position = follow_target.global_position

var test_time = 0.0
func _physics_process(delta):
	# Only update at runtime or if update_in_editor = true
	if (not Engine.is_editor_hint() or update_in_editor) and is_inside_tree():
		# Only update if active or update_when_inactive = true
		# update_when_inactive should only work at runtime, so it
		# does not overwrite update_in_editor
		if is_active or (update_when_inactive or (Engine.is_editor_hint() and update_in_editor)):
			if not should_lock_position:
				match follow_mode:
					CineCamConstants.FollowModes.STATIC:
						pass
					CineCamConstants.FollowModes.PERSPECTIVE:
						if follow_target:
							global_position = follow_target.global_position
					CineCamConstants.FollowModes.FOLLOW:
						if follow_target:
							if is_dampened:
								if rotate_with_target:
									global_position = global_position.lerp(follow_target.to_global(target_offset), delta * follow_speed)
								else:
									global_position = global_position.lerp(follow_target.global_position + target_offset, delta * follow_speed)
							else:
								if rotate_with_target:
									global_position = follow_target.to_global(target_offset)
								else: 
									global_position = follow_target.global_position + target_offset
					CineCamConstants.FollowModes.PATH_FOLLOW:
						_handle_path_follow(delta)
						
			if not should_lock_aim:
				match aim_mode:
					CineCamConstants.AimModes.STATIC:
						pass
					CineCamConstants.AimModes.PERSPECTIVE:
						if aim_target:
							global_rotation = aim_target.global_rotation
					CineCamConstants.AimModes.LOCK_ON:
						if aim_target and aim_target.global_position != global_position:
							look_at(aim_target.global_position)

# Handle the tracking of a given [Path3D]
func _handle_path_follow(delta: float):
	if tracking_path:
		if path_offset > tracking_path.curve.point_count - 1:
			if path_loop:
				path_offset = 0
			else:
				track_ended.emit()
				path_offset = tracking_path.curve.point_count - 1
			
		if move_along and not path_offset >= tracking_path.curve.point_count - 1:
			path_offset += delta * follow_speed

		global_position = tracking_path.global_position + tracking_path.curve.samplef(path_offset)	

func _set(prop_name: StringName, val) -> bool:
	# Assume the property exists
	var retval: bool = true
	
	match prop_name:
		"Follow Settings/Target":
			follow_target = val
		"Follow Settings/Lock Position":
			should_lock_position = val
		"Follow Settings/Speed":
			follow_speed = val
		"Follow Settings/Tracking Path":
			# Reset path offset when path is changed
			path_offset = 0
			tracking_path = val
		"Follow Settings/Offset":
			target_offset = val
		"Follow Settings/Path Offset":
			path_offset = val
		"Follow Settings/Is Dampened":
			is_dampened = val
		"Follow Settings/Move Along":
			move_along = val
		"Follow Settings/Loop":
			path_loop = val
		"Follow Settings/Rotate With Target":
			rotate_with_target = val
		"Aim Settings/Target":
			aim_target = val
		"Aim Settings/Lock Aim":
			should_lock_aim = val
		_:
			retval = false
	
	return retval

func _get(prop_name: StringName):
	match prop_name:
		"Follow Settings/Target":
			return follow_target
		"Follow Settings/Lock Position":
			return should_lock_position
		"Follow Settings/Speed":
			return follow_speed
		"Follow Settings/Tracking Path":
			return tracking_path
		"Follow Settings/Offset":
			return target_offset
		"Follow Settings/Path Offset":
			return path_offset
		"Follow Settings/Is Dampened":
			return is_dampened
		"Follow Settings/Move Along":
			return move_along
		"Follow Settings/Loop":
			return path_loop
		"Follow Settings/Rotate With Target":
			return rotate_with_target
		"Aim Settings/Target":
			return aim_target
		"Aim Settings/Lock Aim":
			return should_lock_aim
	return null

func _get_property_list():
	var properties = []
	for prop in CameraSettings.FollowSettings:
		if follow_mode&prop["flag"] != 0:
			properties.append(prop["object"])
	for prop in CameraSettings.AimSettings:
		if aim_mode&prop["flag"] != 0:
			properties.append(prop["object"])
	return properties
