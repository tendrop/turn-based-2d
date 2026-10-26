extends Node

enum GAME_STATE {
	PLAYER_IDLE,  ## it's player's turn and they're not doing anything
	PLAYER_ACTOR_ACTIVATED, ## PlayerExecutionPanel is shown to player so they can have an actor doing something
	PLAYER_PLOTTING_MOVEMENT ## it's player's turn and they're plotting out movement
}

var __current_game_state: GAME_STATE = GAME_STATE.PLAYER_IDLE
var current_game_state: GAME_STATE:
	get:
		return __current_game_state
	set(new_state):
		if new_state == __current_game_state:
			return
		else:
			# EXIT tasks for current state
			match __current_game_state:
				GAME_STATE.PLAYER_IDLE:
					pass
				
				GAME_STATE.PLAYER_ACTOR_ACTIVATED:
					pass
				
				GAME_STATE.PLAYER_PLOTTING_MOVEMENT:
					SignalManager.on_stop_player_movement_plotting.emit()
			
			# ENTER tasks for new state
			match new_state:
				GAME_STATE.PLAYER_IDLE:
					if activated_actor:
						activated_actor.remove_activation_circle()
						activated_actor = null
					__active_player_task = Statics.PLAYER_TASK.NONE
				
				GAME_STATE.PLAYER_ACTOR_ACTIVATED:
					pass
				
				GAME_STATE.PLAYER_PLOTTING_MOVEMENT:
					SignalManager.on_start_player_movement_plotting.emit(activated_actor)
				
			print("Change GameState from '%s' to '%s'" % [ \
				GAME_STATE.keys()[__current_game_state],
				GAME_STATE.keys()[new_state] \
				])
			__current_game_state = new_state


var __active_player_task: Statics.PLAYER_TASK = Statics.PLAYER_TASK.NONE
var __player_task_count: int = 0

var activated_actor: Actor = null
var selected_actor: Actor = null

func _ready() -> void:
	SignalManager.on_object_selected.connect(_on_object_selected)
	SignalManager.on_object_selection_cleared.connect(_on_object_selection_cleared)


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
				SignalManager.on_show_player_task_two.emit(activated_actor)
				
