extends PanelContainer
class_name KeyboardMap

var header_box: StyleBoxFlat 
var default_color: Color = Statics.ColorDict[Statics.COLORS.GRAY_85]


func _ready() -> void:
	SignalManager.on_game_state_changed.connect(_on_game_state_changed)
	header_box = %HeaderPanel.get_theme_stylebox("panel")

func _on_game_state_changed(new_state: GameStateManager.GAME_STATE) -> void:
	header_box.bg_color = default_color
	%KeyboardSetupLabel.self_modulate = Color.WHITE
	match new_state:
		GameStateManager.GAME_STATE.PLAYER_MOVING, \
		GameStateManager.GAME_STATE.ENEMY_TURN:
			self.visible = false
			
		GameStateManager.GAME_STATE.PLAYER_IDLE:
			%KeyboardSetupLabel.text = "Determine Action"
			self.visible = true
			
		GameStateManager.GAME_STATE.PLAYER_ACTOR_ACTIVATED:
			%KeyboardSetupLabel.text = "%s: Select Actor Task (%d of 2)" % [
				GameStateManager.selected_actor.display_name,
				GameStateManager.current_player_task_count
			]
			__activation_header_colors()
			self.visible = true
			
		GameStateManager.GAME_STATE.PLAYER_PLOTTING_MOVEMENT:
			%KeyboardSetupLabel.text = "Plot Movement Path"
			__activation_header_colors()
			self.visible = true
		
		_:
			%KeyboardSetupLabel.text = GameStateManager.GAME_STATE.keys()[new_state]
			self.visible = true


func __activation_header_colors() -> void:
	header_box.bg_color = Statics.ColorDict[Statics.COLORS.INDIGLO]
	%KeyboardSetupLabel.self_modulate = Color.BLACK
