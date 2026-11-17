extends KeyboardMapButton
class_name Q_KeyboardMapButton

func _on_game_state_changed(new_state: GameStateManager.GAME_STATE) -> void:
	match new_state:
		GameStateManager.GAME_STATE.PLAYER_IDLE, \
		GameStateManager.GAME_STATE.PLAYER_ACTOR_ACTIVATED, \
		GameStateManager.GAME_STATE.PLAYER_PLOTTING_MOVEMENT:
			%CurrentAction.text = "Cancel"
			self.disabled = false
		_:
			%CurrentAction.text = ""
			self.disabled = true


func _on_pressed() -> void:
	super._on_pressed()
	match GameStateManager.current_game_state:
		GameStateManager.GAME_STATE.PLAYER_IDLE:
			SignalManager.on_object_selection_cleared.emit()
			
		GameStateManager.GAME_STATE.PLAYER_ACTOR_ACTIVATED:
			GameStateManager.try_deactivate_actor()
			
		GameStateManager.GAME_STATE.PLAYER_PLOTTING_MOVEMENT:
			SignalManager.on_try_remove_movement_pivot_point.emit()
		_:
			push_error("%s was pressed but did not have an action assigned")
