extends PanelContainer


func _ready() -> void:
	_on_cycle_count_changed(1)
	_on_action_count_changed(GameStateManager.remaining_actions, GameStateManager.max_actions)
	SignalManager.on_cycle_count_changed.connect(_on_cycle_count_changed)
	SignalManager.on_action_count_changed.connect(_on_action_count_changed)


func _on_cycle_count_changed(count: int) -> void:
	%CycleCount.text = "Cycle: %d" % count


func _on_action_count_changed(new_actions: int, max_actions: int) -> void:
	%RemainingActions.text = "Remaining Actions: %d/%d" % [new_actions, max_actions]
