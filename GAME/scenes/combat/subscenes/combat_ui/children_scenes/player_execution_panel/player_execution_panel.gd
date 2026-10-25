extends PanelContainer
class_name PlayerExecutionPanel


func _ready() -> void:
	SignalManager.on_object_selected.connect(_on_object_selected)
	SignalManager.on_object_selection_cleared.connect(_on_object_selection_cleared)
	SignalManager.on_execute_player_action.connect(_on_t1_execute_button_pressed)

func _on_object_selected(n: Node2D) -> void:
	if n is Actor and n.owner_group == Statics.GROUPS.PLAYER_ACTORS:
		# player actor that can take actions is selected
		%T1_ActorName.text = n.display_name
		%T1_MoveButton.grab_focus()
		self.visible = true
		
	else:
		self.visible = false


func _on_object_selection_cleared() -> void:
	self.visible = false


func _on_t1_execute_button_pressed() -> void:
	if not self.visible:
		return
	## TODO: just assumming movement for now
	GameStateManager.active_player_task = Statics.PLAYER_TASK.MOVE
	GameStateManager.current_game_state = GameStateManager.GAME_STATE.PLAYER_PLOTTING_MOVEMENT
