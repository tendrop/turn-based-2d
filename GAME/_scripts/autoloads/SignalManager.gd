extends Node

@warning_ignore_start("unused_signal")

######## CAMERA
## emitted by: Actor
## heard by: CombatCamera
signal on_start_camera_follow(n: Node2D)
signal on_stop_camera_follow

############ KEYHANDLER

## emitted by KeyHandler
## heard by MovementPlotter
## note: since keyhandler is Node, need to use get_local_mouse_position()
## to get coords; can't pass as argument
signal on_world_left_clicked()

## emitted by KeyHandler
## heard by MovementPlotter
signal on_try_remove_movement_pivot_point()

### emitted by KeyHandler
### heard by PlayerExecutionPanel
signal on_execute_player_action()

## emitted by KeyHandler
## heard by MovementPlotter
signal on_start_player_action_pressed()


############## update CombatUI elements
## emitted by: GameStateManager
## heard by: PlayerExecutionPanel
signal on_show_player_task_two(a: Actor)


## emitted by: GameStateManager
## heard by: CombatUi
signal on_object_selected(n: Node2D)
signal on_object_selection_cleared()

## emitted by: Actor
## heard by: GameStateManager
signal on_actor_activated(a: Actor)


## emitted by: lots
## heard by: ScrollingLog (in CombatUi)
signal on_print_message_to_log(msg: String)

## emitted by: KeyHandler
## heard by: PlayerActorsTable
signal on_select_next_player_actor()


## emitted by: MovementPlotter
## heard by: PlayerMovementPanel
signal on_update_player_movement_distance(dist: float)


############### DooDads
signal on_move_hover_circle(visible: bool, global_loc: Vector2)


################ Actions

## player movement plotting
## emitted by: GameStateManager
## heard by: MovementPlotter, PlayerMovementPanel
signal on_start_player_movement_plotting(actor: Actor)
signal on_stop_player_movement_plotting
signal on_make_movement_plot_marker_doodad(global_pos: Vector2)
