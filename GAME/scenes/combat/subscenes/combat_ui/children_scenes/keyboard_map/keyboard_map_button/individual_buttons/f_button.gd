extends KeyboardMapButton
class_name F_KeyboardMapButton

func _on_game_state_changed(new_state: GameStateManager.GAME_STATE) -> void:
	match new_state:
		GameStateManager.GAME_STATE.PLAYER_IDLE:
			%CurrentAction.text = "Activate\nActor"
			self.disabled = false
		_:
			%CurrentAction.text = ""
			self.disabled = true


func _on_pressed() -> void:
	super._on_pressed()
	match GameStateManager.current_game_state:
		GameStateManager.GAME_STATE.PLAYER_IDLE:
			if GameStateManager.selected_actor:
				GameStateManager.selected_actor.activate_me()
		_:
			push_error("%s was pressed but did not have an action assigned")
