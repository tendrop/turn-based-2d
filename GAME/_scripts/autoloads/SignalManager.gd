extends Node

@warning_ignore_start("unused_signal")


############## update CombatUI elements

## emitted by: GameStateManager
## heard by: CombatUi
signal on_object_selected(n: Node2D)
