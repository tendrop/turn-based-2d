extends KeyboardMapButton
class_name Q_KeyboardMapButton

func _on_game_state_changed(new_state: GameStateManager.GAME_STATE) -> void:
	match new_state:
		GameStateManager.GAME_STATE.PLAYER_IDLE:
			%CurrentAction.text = "Clear"
			self.disabled = false
			
		GameStateManager.GAME_STATE.PLAYER_PLOTTING_MOVEMENT:
			%CurrentAction.text = "Undo"
			self.disabled = false
			
		GameStateManager.GAME_STATE.PLAYER_ACTOR_ACTIVATED:
			if GameStateManager.current_player_task_count == GameStateManager.PLAYER_TASK_COUNT.SECOND:
				self.disabled = true
				%CurrentAction.text = ""
			else:
				%CurrentAction.text = "Deactivate"
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
			# will try to remove movement point. if no movement points,
			#  then listener will try to bring back activated-actor keypad
			SignalManager.on_try_remove_movement_pivot_point.emit()
		_:
			push_error("%s was pressed but did not have an action assigned")
