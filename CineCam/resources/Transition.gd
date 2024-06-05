@tool
class_name Transition
extends Resource
## An object representing the data for a transition. Used internally in [TransitionDictionary]

## Signal that a transition has been updated. Used for saving the TransitionDictionary
signal updated

## Name of the VirtualCamera to transition to
@export var to: String = "":
	set(val):
		to = val
		updated.emit()
## Mode of the transition
@export var mode: CineCamConstants.TransitionModes = CineCamConstants.TransitionModes.CUT:
	set(val):
		mode = val
		updated.emit()
## Duration of the transition, in seconds
@export var duration: float = 1.0:
	set(val):
		duration = val
		updated.emit()
## Easing method for transitions with mode [constant CineCamConstants.TransitionModes.EASED]
@export var easing_function: CineCamConstants.EasingModes = CineCamConstants.EasingModes.LINEAR:
	set(val):
		easing_function = val
		updated.emit()
## Flags for what properties to interpolate during a transition with mode [constant CineCamConstants.TransitionModes.EASED]
## Based on [enum CineCamConstants.TransitionProperties]
@export var properties: int = 7:
	set(val):
		properties = val
		updated.emit()

func _init(_to = "", _mode = CineCamConstants.TransitionModes.CUT, _duration = 1.0, _easing = CineCamConstants.EasingModes.LINEAR, _props = 7):
	to = _to
	mode = _mode
	duration = _duration
	easing_function = _easing
	properties = _props

## Return a transition to the given camera with default values
## [codeblock]
##     to = to
##     mode = CineCamConstants.TransitionModes.CUT
##     duration = 1
##     easing = CineCamConstants.EasingModes.LINEAR
##     properties = 7 # All properties
## [/codeblock]
static func get_default(to) -> Transition:
	return Transition.new(to, CineCamConstants.TransitionModes.CUT, 1.0, CineCamConstants.EasingModes.LINEAR, 7)
