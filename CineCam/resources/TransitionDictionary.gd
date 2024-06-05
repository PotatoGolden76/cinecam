@tool
extends Resource
class_name TransitionDictionary
## Custom resource that holds transitions between [VirtualCamera]s
##
## The Transition Dictionary holds a map between a [VirtualCamera] and
## a list of transition to other [VirtualCameras].
## [br][br]
## The plugin uses the name of VirtualCamera nodes to keep track of them,
## ensure there are no duplicate names. If a transition is not present in
## the array, the plugin will use [method Transition.get_default].
## [br][br]
## Refrain from using built-in resources (assigned using 
## [new TransitionDictionary] in the inspector), as they will not
## be saved. Use .tres files instead.

signal cameras_updated
signal transition_added
signal transition_updated
signal transition_removed

## Dictionary of type [String] -> Array[[Transition]] where 
## the key is the name of a [VirtualCamera] and the value is an array
## of [Transition]s from the key to other virtual cameras. 
@export var _transitions: Dictionary

func _init(transitions: Dictionary={}):
	_transitions = transitions

## Get the current list of [VirtualCamera]s of this resource (array of string names).
func get_cameras() -> Array:
	return _transitions.keys()

## Update the list of [VirtualCamera]s
func update_cameras(cameras) -> void:
	var _temp_transitions: Dictionary

	# Copy the transitions if the camera existed before
	# Initialise an empty array if the camera is newly added
	# Transitions for removed cameras get removed
	for cam in cameras:
		if _transitions.has(cam):
			_temp_transitions[cam] = _transitions[cam].duplicate(true)
		else:
			_temp_transitions[cam] = []
	_transitions.clear()
	_transitions = _temp_transitions.duplicate(true)

	# Purge all transitions that lead to non-existent [VirtualCamera]s
	for k in _transitions:
		_transitions[k] = _transitions[k].filter(func(v): return _transitions.has(v.to))

	cameras_updated.emit()

## Get the array of [Transition]s for the given [VirtualCamera]
func get_transitions(cam: String) -> Array:
	return _transitions[cam]
	
## Get the [Transition] object from one [VirtualCamera] to another.
## If it does not exist, the method will return [method Transition.get_default]
func get_transition_or_default(from: String, to: String) -> Transition:
	if _transitions.has(from):
		for transition in _transitions[from]:
			if transition.to == to:
				return transition
	return Transition.get_default(to)

## Get whether there is a [Transition] object from one [VirtualCamera] to another.
func has_transition(from: String, to: String) -> bool:
	if _transitions.has(from):
		for transition in _transitions[from]:
			if transition.to == to:
				return true
	return false

## Add a new [Transition] from the given [VirtualCamera] to [member Transition.to]
func add_transition(from: String, trans: Transition) -> void:
	if _transitions.has(from):
		_transitions[from].append(trans)
	else:
		_transitions[from] = [trans]

	# Connect the update signal. Used for saving the resource
	# trans.updated.connect(update_transition)

	transition_added.emit()

# Used to notify that the resource had updated 
# and should be saved on disk
func update_transition() -> void:
	transition_updated.emit()

## Remove a [Transition] from the given [VirtualCamera] to [member Transition.to]
func remove_transition(from: String, trans: Transition) -> void:
	if _transitions.has(from):
		_transitions[from].erase(trans)
		transition_removed.emit()
