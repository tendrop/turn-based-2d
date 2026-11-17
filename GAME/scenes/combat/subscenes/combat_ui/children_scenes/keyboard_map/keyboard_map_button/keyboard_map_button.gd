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


func reset_to_default() -> void:
	%CurrentAction.text = ""
	self.disabled = true


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
