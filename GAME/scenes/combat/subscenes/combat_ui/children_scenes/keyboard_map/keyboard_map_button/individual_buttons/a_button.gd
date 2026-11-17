extends KeyboardMapButton
class_name A_KeyboardMapButton

func _on_game_state_changed(new_state: GameStateManager.GAME_STATE) -> void:
	match new_state:
		_:
			%CurrentAction.text = ""
			self.disabled = true


func _on_pressed() -> void:
	super._on_pressed()
	match GameStateManager.current_game_state:
		_:
			push_error("%s was pressed but did not have an action assigned")
