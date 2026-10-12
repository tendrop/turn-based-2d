extends CharacterBody2D
class_name Actor

@export var display_name: String = "[Actor]"
@export var owner_group: Statics.GROUPS = Statics.GROUPS.PLAYER_ACTORS


var current_integrity: float = 1.2


func activate_me() -> void:
	#TODO selection circle
	print("%s was activated" % display_name)
	SignalManager.on_player_actor_activated.emit(self)


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		SignalManager.on_print_message_to_log.emit("%s clicked" % display_name)
		GameStateManager.try_select_object(self)


func _on_mouse_entered() -> void:
	SignalManager.on_move_hover_circle.emit(true, self.global_position)


func _on_mouse_exited() -> void:
	SignalManager.on_move_hover_circle.emit(false, Vector2.INF)
