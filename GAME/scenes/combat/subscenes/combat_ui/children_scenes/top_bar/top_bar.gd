extends PanelContainer


func _ready() -> void:
	_on_cycle_count_changed(1)
	_on_execution_count_changed(GameStateManager.remaining_executions, GameStateManager.max_executions)
	SignalManager.on_cycle_count_changed.connect(_on_cycle_count_changed)
	SignalManager.on_execution_count_changed.connect(_on_execution_count_changed)


func _on_cycle_count_changed(count: int) -> void:
	%CycleCount.text = "Cycle: %d" % count


func _on_execution_count_changed(new_exe: int, max_exe: int) -> void:
	%RemainingExecutions.text = "Remaining Executions: %d/%d" % [new_exe, max_exe]
