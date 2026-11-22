extends KeyboardMapButton
class_name F_KeyboardMapButton


func _ready() -> void:
	super._ready()
	SignalManager.on_object_selected.connect(_on_object_selected)
	SignalManager.on_object_selection_cleared.connect(_on_object_selection_cleared)


func _on_game_state_changed(new_state: GameStateManager.GAME_STATE) -> void:
	match new_state:
		GameStateManager.GAME_STATE.PLAYER_IDLE:
			%CurrentAction.text = "Activate\nActor"
			toggle_enabled(GameStateManager.selected_actor != null)
		_:
			%CurrentAction.text = ""
			toggle_enabled(false)


func _on_object_selected(n: Node2D) -> void:
	if GameStateManager.current_game_state == GameStateManager.GAME_STATE.PLAYER_IDLE:
		toggle_enabled(n is Actor)


func _on_object_selection_cleared() -> void:
	toggle_enabled(false)


func _on_pressed() -> void:
	super._on_pressed()
	match GameStateManager.current_game_state:
		GameStateManager.GAME_STATE.PLAYER_IDLE:
			if GameStateManager.selected_actor:
				GameStateManager.selected_actor.activate_me()
		_:
			push_error("%s was pressed but did not have an action assigned")
