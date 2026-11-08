extends CharacterBody2D
class_name Mob

@export var display_name: String = "[Mob]"
@export var owner_group: Statics.GROUPS = Statics.GROUPS.ENEMY_MOBS


func _on_mouse_entered() -> void:
	if Statics.mouse_actions_enabled():
		SignalManager.on_move_hover_circle.emit(true, self.global_position)


func _on_mouse_exited() -> void:
	if Statics.mouse_actions_enabled():
		SignalManager.on_move_hover_circle.emit(false, Vector2.INF)


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if Statics.mouse_actions_enabled():
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			SignalManager.on_print_message_to_log.emit("%s clicked" % display_name)
			SignalManager.on_object_selected.emit(self)
