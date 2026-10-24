extends Node
class_name KeyHandler



func _unhandled_input(event: InputEvent) -> void:

	if event.is_action_pressed("select_next_player_actor"):
		SignalManager.on_select_next_player_actor.emit()
		get_viewport().set_input_as_handled()
	
	elif event.is_action_pressed("clear_selection"):
		match GameStateManager.current_game_state:
			GameStateManager.GAME_STATE.PLAYER_IDLE, GameStateManager.GAME_STATE.OBJECT_SELECTED:
				GameStateManager.try_clear_selection()
				get_viewport().set_input_as_handled()
			GameStateManager.GAME_STATE.PLAYER_PLOTTING_MOVEMENT:
				SignalManager.on_try_remove_movement_pivot_point.emit()

	elif event is InputEventMouseButton and event.pressed:
		match (event as InputEventMouseButton).button_index:
			MOUSE_BUTTON_LEFT:
				match GameStateManager.current_game_state:
					GameStateManager.GAME_STATE.PLAYER_PLOTTING_MOVEMENT:
						SignalManager.on_world_left_clicked.emit()
						get_viewport().set_input_as_handled()
	
	elif event.is_action_pressed("ui_accept"):
		SignalManager.on_enter_key_pressed.emit()
		get_viewport().set_input_as_handled()
		
	elif event.is_action_pressed("start_player_action"):
		match GameStateManager.current_game_state:
			GameStateManager.GAME_STATE.PLAYER_PLOTTING_MOVEMENT:
				SignalManager.on_start_player_action_pressed.emit()
				get_viewport().set_input_as_handled()
		
