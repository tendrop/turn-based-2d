extends PanelContainer
class_name PlayerExecutionPanel

var __is_task_one: bool = true

func _ready() -> void:
	SignalManager.on_actor_activated.connect(_on_actor_activated)
	SignalManager.on_object_selection_cleared.connect(_on_object_selection_cleared)
	SignalManager.on_execute_player_action.connect(_on_execute_signal_sent)
	SignalManager.on_show_player_task_two.connect(_on_show_player_task_two)


func _on_show_player_task_two(actor: Actor) -> void:
	__setup_panel_design(actor, false)


## show for task #1 when player Actor is selected
func _on_actor_activated(a: Actor) -> void:
	if a.owner_group == Statics.GROUPS.PLAYER_ACTORS:
		__setup_panel_design(a, true)
	else:
		self.visible = false


func _on_object_selection_cleared() -> void:
	self.visible = false


func __setup_panel_design(a: Actor, is_task_one: bool) -> void:
	if is_task_one:
		%ActorName.text = a.display_name
		%TaskNumberLabel.text = "Set Execution Task (1 of 2)"
		%MoveButton.grab_focus()
	else:
		%TaskNumberLabel.text = "Set Execution Task (2 of 2)"
		%AttackButton.grab_focus()

	# can't use these buttons in task #2
	%InteractButton.disabled = not is_task_one
	%BigShotButton.disabled = not is_task_one
	%Turn1_ExecuteButton.visible = is_task_one
	%Turn1_ExecuteButton.disabled = not is_task_one
	%Turn2_ExecuteButton.visible = not is_task_one
	%Turn2_ExecuteButton.disabled = is_task_one
	__is_task_one = is_task_one
	self.visible = true


func _on_execute_signal_sent() -> void:
	if __is_task_one:
		_on_t1_execute_button_pressed()
	else:
		_on_t2_execute_button_pressed()


func _on_t1_execute_button_pressed() -> void:
	if not self.visible:
		return
	else:
		GameStateManager.start_player_task(1, __get_selected_task())
		self.visible = false


func _on_t2_execute_button_pressed() -> void:
	if not self.visible:
		return
	else:
		GameStateManager.start_player_task(2, __get_selected_task())
		self.visible = false
	

func __get_selected_task() -> Statics.PLAYER_TASK:
	if %MoveButton.button_pressed:
		return Statics.PLAYER_TASK.MOVE
	else:
		push_error("player_execution_panel._on_t1_execute_button_pressed can only handle MOVE for now")
		return Statics.PLAYER_TASK.MOVE
