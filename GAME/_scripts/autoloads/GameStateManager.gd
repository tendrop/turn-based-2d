extends Node

enum GAME_STATE {
	PLAYER_IDLE,  ## it's player's turn and they're not doing anything
	PLAYER_ACTOR_ACTIVATED, ## PlayerExecutionPanel is shown to player so they can have an actor doing something
	PLAYER_PLOTTING_MOVEMENT, ## it's player's turn and they're plotting out movement
	ENEMY_TURN
}


## changed when ENEMY_TURN is over
var ___current_cycle: int = 1
var current_cycle: int:
	get:
		return ___current_cycle
	set(value):
		___current_cycle = value
		SignalManager.on_cycle_count_changed.emit(value)


var max_executions: int = 1
var ___remaining_executions: int = 0
var remaining_executions: int:
	get:
		return ___remaining_executions
	set(value):
		___remaining_executions = value
		SignalManager.on_execution_count_changed.emit(value, max_executions)
		if ___remaining_executions == 0:
			push_warning("NOW DO ENEMY TURN")
			current_game_state = GAME_STATE.ENEMY_TURN


var ___current_game_state: GAME_STATE = GAME_STATE.PLAYER_IDLE
var current_game_state: GAME_STATE:
	get:
		return ___current_game_state
	set(new_state):
		if new_state == ___current_game_state:
			return
		else:
			# EXIT tasks for current state
			match ___current_game_state:
				GAME_STATE.PLAYER_IDLE:
					pass
				
				GAME_STATE.PLAYER_ACTOR_ACTIVATED:
					pass
				
				GAME_STATE.PLAYER_PLOTTING_MOVEMENT:
					SignalManager.on_stop_player_movement_plotting.emit()
				
				GAME_STATE.ENEMY_TURN:
					remaining_executions = max_executions
					current_cycle += 1
			
			
			# ENTER tasks for new state
			match new_state:
				GAME_STATE.PLAYER_IDLE:
					if activated_actor:
						activated_actor.remove_activation_circle()
						activated_actor = null
					__active_player_task = Statics.PLAYER_TASK.NONE
					__player_task_count = 0
				
				GAME_STATE.PLAYER_ACTOR_ACTIVATED:
					pass
				
				GAME_STATE.PLAYER_PLOTTING_MOVEMENT:
					SignalManager.on_start_player_movement_plotting.emit(activated_actor)
				
				GAME_STATE.ENEMY_TURN:
					pass
				
			print("Change GameState from '%s' to '%s'" % [ \
				GAME_STATE.keys()[___current_game_state],
				GAME_STATE.keys()[new_state] \
				])
			___current_game_state = new_state


var __active_player_task: Statics.PLAYER_TASK = Statics.PLAYER_TASK.NONE
var __player_task_count: int = 0

var activated_actor: Actor = null
var selected_actor: Actor = null

func _ready() -> void:
	SignalManager.on_object_selected.connect(_on_object_selected)
	SignalManager.on_object_selection_cleared.connect(_on_object_selection_cleared)
	remaining_executions = max_executions


func _on_object_selected(n: Node2D) -> void:
	if n and n is Actor:
		selected_actor = n


func _on_object_selection_cleared() -> void:
	selected_actor = null


func try_activate_actor(actor: Actor) -> void:
	if actor != selected_actor: return
	activated_actor = actor
	current_game_state = GAME_STATE.PLAYER_ACTOR_ACTIVATED
	SignalManager.on_actor_activated.emit(actor)


func start_player_task(task_number: int, task_type: Statics.PLAYER_TASK) -> void:
	__active_player_task = task_type
	__player_task_count = task_number
	
	match task_type:
		Statics.PLAYER_TASK.MOVE:
			GameStateManager.current_game_state = GameStateManager.GAME_STATE.PLAYER_PLOTTING_MOVEMENT


func handle_player_execution_task_complete() -> void:
	#  if player has another action, show player execution panel again. 
	if __player_task_count == 2:
		# second task done, always return to idle
		current_game_state = GAME_STATE.PLAYER_IDLE
		remaining_executions -= 1
		
	else:
		current_game_state = GAME_STATE.PLAYER_ACTOR_ACTIVATED
		__player_task_count = 2
		# single task done
		match __active_player_task:
			Statics.PLAYER_TASK.INFILTRATE:
				# no follow-up task allowed, return to IDLE
				current_game_state = GAME_STATE.PLAYER_IDLE
			
			Statics.PLAYER_TASK.MOVE:
				SignalManager.on_show_player_task_two.emit(activated_actor)
				
