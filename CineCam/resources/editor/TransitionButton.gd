@tool
extends PanelContainer

var toggle_icons = [
	preload ("res://addons/CineCam/assets/icons/ArrowRight.svg"),
	preload ("res://addons/CineCam/assets/icons/ArrowDown.svg")]
var camera_icon = preload("res://addons/CineCam/assets/gizmos/VirtualCamera.svg")

signal updated
signal remove(t: Transition)

# Toolbar Controls
@onready var _expand_button: Button = $Wrapper/Toolbar/Container/Toggle
@onready var _remove_button: Button = $Wrapper/Toolbar/Container/Remove
@onready var _camera_selector: OptionButton = $Wrapper/Toolbar/Container/CameraSelect
@onready var _mode_selector: OptionButton = $Wrapper/Toolbar/Container/ModeSelect

# Collapsible Controls
@onready var collapsible = $Wrapper/Collapsible
# _easing_setting represents the label + input for the easing function
# only referenced in order to show/hide based on the selected mode
@onready var _easing_setting = $Wrapper/Collapsible/Split/ModeWrapper/Scroll/Container/Easing
@onready var _easing_selector: OptionButton = $Wrapper/Collapsible/Split/ModeWrapper/Scroll/Container/Easing/Select
@onready var _duration_input: SpinBox = $Wrapper/Collapsible/Split/ModeWrapper/Scroll/Container/Duration/Input
# Array of Checkboxes
@onready var _properties_checkboxes: Array[Node] = $Wrapper/Collapsible/Split/PropertiesWrapper/Scroll/Container/Checkboxes.get_children()

## The [Transition] object assigned to this button
var transition: Transition
## The name of the camera currently selected in [TransitionEditor]
var current_camera: String = ""

func _ready():
	# Connect the signals for all of the input elements
	_expand_button.pressed.connect(toggle_panel)
	_mode_selector.item_selected.connect(_update_mode_selected)
	_camera_selector.item_selected.connect(_update_camera_selected)
	_remove_button.button_up.connect(_remove)

	_easing_selector.item_selected.connect(_update_easing_selected)
	_duration_input.value_changed.connect(_update_duration)

	for idx in len(_properties_checkboxes):
		_properties_checkboxes[idx].toggled.connect(_update_property.bind(idx))

## Assign a [Transition] to this button after initialisation
func set_transition(t: Transition, current: String):
	transition = t
	current_camera = current

	# Populate inputs with the values saved in the [Transition]
	_mode_selector.select(transition.mode)
	_easing_selector.select(transition.easing_function)
	_easing_setting.visible = (transition.mode == CineCamConstants.TransitionModes.EASED)
	_duration_input.set_value_no_signal(transition.duration)

	for idx in len(_properties_checkboxes):
		_properties_checkboxes[idx].set_pressed_no_signal(transition.properties & int(pow(2, idx)))

## Set the current list of cameras.
## Used to populate the camera dropdown.
func set_cameras(cams: Array):
	_camera_selector.clear()
	var i = 0
	for c in cams:
		# Do not add the selected camera to the dropdown
		# A camera can't transition from itself to itself
		if c != current_camera:
			_camera_selector.add_icon_item(camera_icon, c)
			if c == transition.to:
				_camera_selector.select(i)
			i += 1

## Toggle the collapsible panel
func toggle_panel():
	collapsible.visible = !collapsible.visible
	_expand_button.icon = toggle_icons[1 if collapsible.visible else 0]

# Methods to handle the input signals
func _update_camera_selected(index: int):
	transition.to = _camera_selector.get_item_text(index)
	updated.emit()

func _update_mode_selected(index: int):
	transition.mode = _mode_selector.get_item_id(index)
	_easing_setting.visible = (transition.mode == CineCamConstants.TransitionModes.EASED)
	updated.emit()

func _update_easing_selected(index: int):
	transition.easing_function = _easing_selector.get_item_id(index)
	updated.emit()

func _update_duration(value: float):
	transition.duration = value
	updated.emit()

func _update_property(state: bool, index: int):
	transition.properties ^= int(pow(2, index))
	updated.emit()

func _remove():
	remove.emit(transition)