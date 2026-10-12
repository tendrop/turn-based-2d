extends Node

@warning_ignore_start("unused_signal")


############## update CombatUI elements

## emitted by: GameStateManager
## heard by: CombatUi
signal on_object_selected(n: Node2D)
signal on_object_selection_cleared()

## emitted by: lots
## heard by: ScrollingLog (in CombatUi)
signal on_print_message_to_log(msg: String)

## emitted by: KeyHandler
## heard by: PlayerActorsTable
signal on_select_next_player_actor()



############### DooDads
signal on_move_hover_circle(visible: bool, global_loc: Vector2)
