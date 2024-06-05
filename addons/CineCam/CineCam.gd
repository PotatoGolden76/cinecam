@tool
extends EditorPlugin

## Transition Editor scene
const TransitionEditor = preload("res://addons/CineCam/resources/editor/TransitionEditor.tscn")
## Instance of the active transition editor
var _transition_editor_instance

func _enter_tree():
	_transition_editor_instance = TransitionEditor.instantiate()
	add_control_to_bottom_panel(_transition_editor_instance, "Transitions")
	# Hide the editor on startup
	_make_visible(false)

## Redirect resource editing to our own plugin when a [TransitionDictionary] 
## is selected in the inspector
func _handles(object):
	if object is TransitionDictionary:
		_transition_editor_instance.set_current_resource(object)
		# workaround for issues related to issue [#84673] from the
		# Godot GitHub repository
		hide_bottom_panel()
		_make_visible(true)
		return true
	return false

## Toggle TransitionEditor visibility
func _make_visible(visible):
	if _transition_editor_instance:
		_transition_editor_instance.visible = visible

## Cleanup
func _exit_tree():
	if _transition_editor_instance:
		remove_control_from_bottom_panel(_transition_editor_instance)
		_transition_editor_instance.queue_free()

