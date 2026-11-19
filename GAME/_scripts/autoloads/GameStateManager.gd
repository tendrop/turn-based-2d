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

## EMENY ACTIONS
var total_enemy_actions: int = 1

## PLAYER ACTIONS
var max_actions: int = 1
var ___remaining_actions: int = 0
var remaining_actions: int:
	get:
		return ___remaining_actions
	set(value):
		___remaining_actions = value
		SignalManager.on_action_count_changed.emit(value, max_actions)
		if ___remaining_actions == 0:
			player_task_count = 0
			current_game_state = GAME_STATE.ENEMY_TURN


var ___current_game_state: GAME_STATE = GAME_STATE.PLAYER_IDLE
var current_game_state: GAME_STATE:
	get:
		return ___current_game_state
	set(new_state):
		if new_state == ___current_game_state:
			return
		else:
			print("Changing GameState from '%s' to '%s'" % [ \
				GAME_STATE.keys()[___current_game_state],
				GAME_STATE.keys()[new_state] \
				])
			
			# EXIT tasks for current state
			match ___current_game_state:
				GAME_STATE.PLAYER_IDLE:
					pass
				
				GAME_STATE.PLAYER_ACTOR_ACTIVATED:
					pass
				
				GAME_STATE.PLAYER_PLOTTING_MOVEMENT:
					pass
				
				GAME_STATE.ENEMY_TURN:
					remaining_actions = max_actions
					current_cycle += 1
			
			
			# ENTER tasks for new state
			match new_state:
				GAME_STATE.PLAYER_IDLE:
					if activated_actor:
						activated_actor.remove_activation_circle()
						activated_actor = null
					__active_player_task = Statics.PLAYER_TASK.NONE
					player_task_count = 0
					
				GAME_STATE.PLAYER_ACTOR_ACTIVATED:
					pass
				
				GAME_STATE.PLAYER_PLOTTING_MOVEMENT:
					pass
				
				GAME_STATE.ENEMY_TURN:
					SignalManager.on_start_enemy_turn.emit(total_enemy_actions)
			
			___current_game_state = new_state
			SignalManager.on_game_state_changed.emit(new_state)


var __active_player_task: Statics.PLAYER_TASK = Statics.PLAYER_TASK.NONE
## 0: player not activated // 1: player initial activation, no task done yet
## 2: first task complete, ready for second
var player_task_count: int = 0

var activated_actor: Actor = null
var selected_actor: Actor = null


func _ready() -> void:
	SignalManager.on_object_selected.connect(_on_object_selected)
	SignalManager.on_object_selection_cleared.connect(_on_object_selection_cleared)
	SignalManager.on_end_enemy_turn.connect(_on_end_enemy_turn)
	remaining_actions = max_actions


func _on_object_selected(n: Node2D) -> void:
	if n and n is Actor:
		selected_actor = n
	else:
		selected_actor = null


func _on_object_selection_cleared() -> void:
	selected_actor = null


func _on_end_enemy_turn() -> void:
	current_game_state = GAME_STATE.PLAYER_IDLE


func try_activate_actor(actor: Actor) -> void:
	if actor != selected_actor: return
	if current_game_state != GAME_STATE.PLAYER_IDLE: return
	if player_task_count != 0: return
	
	if activated_actor:
		activated_actor.remove_activation_circle()
	activated_actor = actor
	current_game_state = GAME_STATE.PLAYER_ACTOR_ACTIVATED
	player_task_count = 1
	SignalManager.on_actor_activated.emit(actor)


func try_deactivate_actor() -> void:
	if activated_actor \
	and player_task_count < 2:
		match current_game_state:
			GAME_STATE.PLAYER_ACTOR_ACTIVATED:
				SignalManager.on_object_selection_cleared.emit()
				self.current_game_state = GAME_STATE.PLAYER_IDLE
			GAME_STATE.PLAYER_PLOTTING_MOVEMENT:
				player_task_count -= 1
				self.current_game_state = GAME_STATE.PLAYER_ACTOR_ACTIVATED


func start_player_task(task_type: Statics.PLAYER_TASK) -> void:
	__active_player_task = task_type

	match task_type:
		Statics.PLAYER_TASK.MOVE:
			GameStateManager.current_game_state = GameStateManager.GAME_STATE.PLAYER_PLOTTING_MOVEMENT


func handle_player_actor_task_complete() -> void:
	#  if player has another action, show player execution panel again. 
	if player_task_count == 2:
		# second task done, always return to idle
		current_game_state = GAME_STATE.PLAYER_IDLE
		remaining_actions -= 1
		
	else:
		# single task done
		match __active_player_task:
			Statics.PLAYER_TASK.INFILTRATE:
				# no follow-up task allowed, return to IDLE
				current_game_state = GAME_STATE.PLAYER_IDLE
				return
			
			Statics.PLAYER_TASK.MOVE:
				SignalManager.on_show_player_task_two.emit(activated_actor)
		
		player_task_count = 2
		current_game_state = GAME_STATE.PLAYER_ACTOR_ACTIVATED
				
