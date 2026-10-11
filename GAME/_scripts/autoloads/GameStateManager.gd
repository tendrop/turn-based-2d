extends Node

enum GAME_STATE {
	PLAYER_IDLE,
	OBJECT_SELECTED,
	ACTOR_ACTIVATED,
	PLAYER_TURN_RUNNING,
	ENEMY_TURN_RUNNING
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
					if new_state != GAME_STATE.ACTOR_ACTIVATED:
						__current_actor = null
						SignalManager.on_object_selection_cleared.emit()
				GAME_STATE.ACTOR_ACTIVATED:
					pass
				GAME_STATE.PLAYER_TURN_RUNNING:
					pass
				GAME_STATE.ENEMY_TURN_RUNNING:
					pass
			
			# ENTER tasks for new state
			match new_state:
				GAME_STATE.PLAYER_IDLE:
					pass
				GAME_STATE.OBJECT_SELECTED:
					pass
				GAME_STATE.ACTOR_ACTIVATED:
					pass
				GAME_STATE.PLAYER_TURN_RUNNING:
					pass
				GAME_STATE.ENEMY_TURN_RUNNING:
					pass
				
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


func try_select_object(obj: Node2D) -> void:
	if "display_name" in obj:
		print("selcting %s when state is %s" % [obj.display_name, GAME_STATE.keys()[current_game_state]])
		match current_game_state:
			GAME_STATE.PLAYER_IDLE, GAME_STATE.ACTOR_ACTIVATED:
				__select_object(obj)
			
			GAME_STATE.OBJECT_SELECTED:
				if current_actor == obj: #&& obj.owner_group == Statics.GROUPS.PLAYER_ACTORS:
					print("actor already selected, trying to activate")
					## TODO
					# try_activate_actor()
				else:
					__select_object(obj)


func __select_object(obj: Node2D) -> void:
	SignalManager.on_object_selected.emit(obj)
	if obj is Actor:
		__current_actor = obj
	else:
		__current_actor = null
	current_game_state = GAME_STATE.OBJECT_SELECTED


## called by KeyHandler when backspace is pressed
func try_clear_selection() -> void:
	match current_game_state:
		GAME_STATE.OBJECT_SELECTED:
			current_game_state = GAME_STATE.PLAYER_IDLE
		GAME_STATE.ACTOR_ACTIVATED:
			# first push of backspace button returns to prev state (actor selected)
			current_game_state = GAME_STATE.OBJECT_SELECTED
