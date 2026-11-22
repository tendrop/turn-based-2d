extends KeyboardMapButton
class_name R_KeyboardMapButton

func _on_game_state_changed(new_state: GameStateManager.GAME_STATE) -> void:
	match new_state:
		GameStateManager.GAME_STATE.PLAYER_ACTOR_ACTIVATED:
			%CurrentAction.text = "Move"
			toggle_enabled(true)
		GameStateManager.GAME_STATE.PLAYER_PLOTTING_MOVEMENT:
			%CurrentAction.text = "Commit\nMove"
			toggle_enabled(true)
		_:
			%CurrentAction.text = ""
			toggle_enabled(false)


func _on_pressed() -> void:
	super._on_pressed()
	match GameStateManager.current_game_state:
		GameStateManager.GAME_STATE.PLAYER_ACTOR_ACTIVATED:
			GameStateManager.start_player_task(Statics.PLAYER_TASK.MOVE)
		
		GameStateManager.GAME_STATE.PLAYER_PLOTTING_MOVEMENT:
			GameStateManager.try_start_player_move()
		
		_:
			push_error("%s was pressed but did not have an action assigned")
