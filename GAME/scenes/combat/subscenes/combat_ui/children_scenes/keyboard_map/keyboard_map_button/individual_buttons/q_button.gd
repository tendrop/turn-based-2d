extends KeyboardMapButton
class_name Q_KeyboardMapButton


func _ready() -> void:
	super._ready()
	SignalManager.on_object_selected.connect(_on_object_selected)
	SignalManager.on_object_selection_cleared.connect(_on_object_selection_cleared)


func _on_game_state_changed(new_state: GameStateManager.GAME_STATE) -> void:
	match new_state:
		GameStateManager.GAME_STATE.PLAYER_IDLE:
			%CurrentAction.text = "Clear"
			toggle_enabled(false)
			
		GameStateManager.GAME_STATE.PLAYER_PLOTTING_MOVEMENT:
			%CurrentAction.text = "Undo"
			toggle_enabled(true)
			
		GameStateManager.GAME_STATE.PLAYER_ACTOR_ACTIVATED:
			if GameStateManager.current_player_task_count == GameStateManager.PLAYER_TASK_COUNT.SECOND:
				toggle_enabled(false)
				%CurrentAction.text = ""
			else:
				%CurrentAction.text = "Deactivate"
				toggle_enabled(true)
		_:
			%CurrentAction.text = ""
			toggle_enabled(false)

func _on_object_selected(n: Node2D) -> void:
	if GameStateManager.current_game_state == GameStateManager.GAME_STATE.PLAYER_IDLE:
		if n == null:
			await get_tree().create_timer(0.2).timeout
			toggle_enabled(false)
		else:
			toggle_enabled(true)


func _on_object_selection_cleared() -> void:
	if GameStateManager.current_game_state == GameStateManager.GAME_STATE.PLAYER_IDLE:
		await get_tree().create_timer(0.2).timeout
		toggle_enabled(false)


func _on_pressed() -> void:
	#super._on_pressed()
	match GameStateManager.current_game_state:
		GameStateManager.GAME_STATE.PLAYER_IDLE:
			super._on_pressed()
			SignalManager.on_object_selection_cleared.emit()
			
		GameStateManager.GAME_STATE.PLAYER_ACTOR_ACTIVATED:
			GameStateManager.try_deactivate_actor()
			
		GameStateManager.GAME_STATE.PLAYER_PLOTTING_MOVEMENT:
			# will try to remove movement point. if no movement points,
			#  then listener will try to bring back activated-actor keypad
			super._on_pressed()
			SignalManager.on_try_remove_movement_pivot_point.emit()
		_:
			push_error("%s was pressed but did not have an action assigned")
