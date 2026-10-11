extends Node
class_name KeyHandler



func _unhandled_input(event: InputEvent) -> void:

	if event.is_action_pressed("select_next_player_actor"):
		SignalManager.on_select_next_player_actor.emit()
		get_viewport().set_input_as_handled()
	
	elif event.is_action_pressed("clear_selection"):
		GameStateManager.try_clear_selection()
		get_viewport().set_input_as_handled()
