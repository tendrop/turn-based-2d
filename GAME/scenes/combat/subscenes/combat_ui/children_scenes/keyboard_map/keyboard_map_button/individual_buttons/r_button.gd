extends KeyboardMapButton
class_name R_KeyboardMapButton

func _on_game_state_changed(new_state: GameStateManager.GAME_STATE) -> void:
	match new_state:
		GameStateManager.GAME_STATE.PLAYER_ACTOR_ACTIVATED:
			%CurrentAction.text = "Move"
			self.disabled = false
		GameStateManager.GAME_STATE.PLAYER_PLOTTING_MOVEMENT:
			%CurrentAction.text = "Commit\nMove"
			self.disabled = false
		_:
			%CurrentAction.text = ""
			self.disabled = true


func _on_pressed() -> void:
	super._on_pressed()
	match GameStateManager.current_game_state:
		GameStateManager.GAME_STATE.PLAYER_ACTOR_ACTIVATED:
			GameStateManager.start_player_task(Statics.PLAYER_TASK.MOVE)
		
		GameStateManager.GAME_STATE.PLAYER_PLOTTING_MOVEMENT:
			# movement_plotter will hear this
			GameStateManager.current_game_state = GameStateManager.GAME_STATE.PLAYER_MOVING
		
		_:
			push_error("%s was pressed but did not have an action assigned")
