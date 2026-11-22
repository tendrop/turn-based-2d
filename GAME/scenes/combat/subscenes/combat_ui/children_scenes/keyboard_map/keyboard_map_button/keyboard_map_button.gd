extends Button
class_name KeyboardMapButton


func _ready() -> void:
	var key_letter: String = "?"
	if self.shortcut != null:
		for e in self.shortcut.events:
			if e is InputEventKey and e.physical_keycode != KEY_NONE:
				var local := DisplayServer.keyboard_get_keycode_from_physical(e.physical_keycode)
				key_letter = OS.get_keycode_string(local)
				break
	%Key.text = key_letter
	SignalManager.on_game_state_changed.connect(_on_game_state_changed)
	_on_game_state_changed(GameStateManager.GAME_STATE.PLAYER_IDLE)


func reset_to_default() -> void:
	%CurrentAction.text = ""
	toggle_enabled(false)


func toggle_enabled(enabled: bool) -> void:
	if enabled:
		self.disabled = false
		%CurrentAction.self_modulate = Color.WHITE
	else:
		self.disabled = true
		%CurrentAction.self_modulate = Statics.ColorDict[Statics.COLORS.GRAY_33]


func set_key_text(letter: String) -> void:
	var action: String = "%s_key" % letter
	var events = InputMap.action_get_events(action)
	for e in events:
		if e is InputEventKey and e.physical_keycode != KEY_NONE:
			var local := DisplayServer.keyboard_get_keycode_from_physical(e.physical_keycode)
			%Key.text = OS.get_keycode_string(local)
			return 
	# if got here, then nothing was found so just show letter as-is
	%Key.text = letter.to_upper()
	return


func _on_game_state_changed(new_state: GameStateManager.GAME_STATE) -> void:
	if new_state:
		push_error("%s does not have _on_game_state_changed hooked up" % self.name)


func _on_pressed() -> void:
	var tween := create_tween()
	tween.tween_property(%CurrentAction, "modulate", Color.BLACK, 0.2)
	await tween.finished
	%CurrentAction.modulate = Color.WHITE
