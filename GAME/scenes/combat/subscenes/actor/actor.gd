extends CharacterBody2D
class_name Actor

@export var display_name: String = "[Actor]"

var current_integrity: float = 1.2

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		SignalManager.on_print_message_to_log.emit("%s clicked" % display_name)
		GameStateManager.try_select_object(self)


func _on_mouse_entered() -> void:
	print("mouse entered %s" % display_name)


func _on_mouse_exited() -> void:
	print("mouse exited %s" % display_name)
