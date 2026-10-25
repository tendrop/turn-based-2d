extends Node

enum GAME_STATE {
	PLAYER_IDLE,  ## it's player's turn and they're not doing anything
	OBJECT_SELECTED, ## it's player's turn and they've left-clicked on something
	PLAYER_PLOTTING_MOVEMENT ## it's player's turn and they're plotting out movement
}

var __current_game_state: GAME_STATE = GAME_STATE.PLAYER_IDLE
var current_game_state: GAME_STATE:
	get:
		return __current_game_state
	set(new_state):
		if new_state == __current_game_state:
			# do nothing
			if new_state != GAME_STATE.OBJECT_SELECTED:
				push_warning("attempted to change state, but already in %s" % GAME_STATE.keys()[current_game_state])
		else:
			# EXIT tasks for current state
			match __current_game_state:
				GAME_STATE.PLAYER_IDLE:
					pass
				GAME_STATE.OBJECT_SELECTED:
					SignalManager.on_object_selection_cleared.emit()
				
				GAME_STATE.PLAYER_PLOTTING_MOVEMENT:
					SignalManager.on_stop_player_movement_plotting.emit()
			
			# ENTER tasks for new state
			match new_state:
				GAME_STATE.PLAYER_IDLE:
					current_actor = null
					__active_player_task = Statics.PLAYER_TASK.NONE
					
				GAME_STATE.OBJECT_SELECTED:
					pass
				
				GAME_STATE.PLAYER_PLOTTING_MOVEMENT:
					SignalManager.on_start_player_movement_plotting.emit(current_actor)
				
			print("Change GameState from '%s' to '%s'" % [ \
				GAME_STATE.keys()[__current_game_state],
				GAME_STATE.keys()[new_state] \
				])
			__current_game_state = new_state


var __active_player_task: Statics.PLAYER_TASK = Statics.PLAYER_TASK.NONE
var __player_task_count: int = 0

#var __previous_actor: Actor = null
var __current_actor: Actor = null
var current_actor: Actor:
	get:
		return __current_actor
	set(value):
		#__previous_actor = __current_actor
		__current_actor = value


func try_select_object(obj: Node2D) -> void:
	if "display_name" in obj:
		print("selcting %s when state is %s" % [obj.display_name, GAME_STATE.keys()[current_game_state]])
		match current_game_state:
			GAME_STATE.PLAYER_IDLE, GAME_STATE.OBJECT_SELECTED:
				print("trying to select it...")
				__select_object(obj)


func __select_object(obj: Node2D) -> void:
	if current_actor != obj:
		print("selecting object")
		SignalManager.on_object_selected.emit(obj)
		if obj is Actor:
			current_actor = obj
		else:
			current_actor = null
		current_game_state = GAME_STATE.OBJECT_SELECTED
	else:
		print("did not select it")


## called by KeyHandler when 'clear_selection' is pressed (currently mapped to [Z])
func try_clear_selection() -> void:
	match current_game_state:
		GAME_STATE.OBJECT_SELECTED:
			current_game_state = GAME_STATE.PLAYER_IDLE


func start_player_task(task_number: int, task_type: Statics.PLAYER_TASK) -> void:
	__active_player_task = task_type
	__player_task_count = task_number
	
	match task_type:
		Statics.PLAYER_TASK.MOVE:
			GameStateManager.current_game_state = GameStateManager.GAME_STATE.PLAYER_PLOTTING_MOVEMENT


func handle_player_movement_complete() -> void:
	#  if player has another action, show player execution panel again. 
	if __player_task_count == 2:
		# second task done, always return to idle
		current_game_state = GAME_STATE.PLAYER_IDLE
		
	else:
		# single task done
		match __active_player_task:
			Statics.PLAYER_TASK.INFILTRATE:
				# no follow-up task allowed, return to IDLE
				current_game_state = GAME_STATE.PLAYER_IDLE
			
			Statics.PLAYER_TASK.MOVE:
				SignalManager.on_show_player_task_two.emit(current_actor)
				
