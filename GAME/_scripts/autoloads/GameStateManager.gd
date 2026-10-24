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
					__previous_actor = __current_actor
					__current_actor = null
					SignalManager.on_object_selection_cleared.emit()
				GAME_STATE.PLAYER_PLOTTING_MOVEMENT:
					SignalManager.on_stop_player_movement_plotting.emit()
			
			# ENTER tasks for new state
			match new_state:
				GAME_STATE.PLAYER_IDLE:
					pass
				GAME_STATE.OBJECT_SELECTED:
					pass
				GAME_STATE.PLAYER_PLOTTING_MOVEMENT:
					SignalManager.on_start_player_movement_plotting.emit(__previous_actor)
				
			print("Change GameState from '%s' to '%s'" % [ \
				GAME_STATE.keys()[__current_game_state],
				GAME_STATE.keys()[new_state] \
				])
			__current_game_state = new_state


var __current_actor: Actor = null
var current_actor: Actor:
	get:
		return __current_actor
	set(value):
		## PRIVATE SET, SHOULD ONLY BE DONE BY GAMESTATEMANAGER
		push_warning("GameStateManager.current_actor was tried to set manually in error. don't do that.")

var __previous_actor: Actor = null

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
			__previous_actor = __current_actor
			__current_actor = obj
		else:
			__previous_actor = __current_actor
			__current_actor = null
		current_game_state = GAME_STATE.OBJECT_SELECTED
	else:
		print("did not select it")


## called by KeyHandler when backspace is pressed
func try_clear_selection() -> void:
	match current_game_state:
		GAME_STATE.OBJECT_SELECTED:
			current_game_state = GAME_STATE.PLAYER_IDLE


# called by MovementPlotter after player pushed spacebar
func start_player_movement(actor: Actor, coords: Array[Vector2]) -> void:
	# TODO disable keyboard/mouse
	# this might need to be awaited
	actor.do_movement(coords)
	print("is this printed before movement is done?")
	# TODO go to second action if not infiltrating or sniping, otherwise back to idle state
