extends PanelContainer
class_name KeyboardMap


func _ready() -> void:
	SignalManager.on_game_state_changed.connect(_on_game_state_changed)


func _on_game_state_changed(new_state: GameStateManager.GAME_STATE) -> void:
	%KeyboardSetupLabel.text = GameStateManager.GAME_STATE.keys()[new_state]
	match new_state:
		GameStateManager.GAME_STATE.PLAYER_MOVING, \
		GameStateManager.GAME_STATE.ENEMY_TURN:
			self.visible = false
		_:
			self.visible = true
