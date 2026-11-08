extends Sprite2D
class_name HoverCircle


func _ready() -> void:
	SignalManager.on_move_hover_circle.connect(_on_move_hover_circle)
	SignalManager.on_object_selection_cleared.connect(_on_hide)


func _on_move_hover_circle(my_visible: bool, global_loc: Vector2) -> void:
	if Input.get_current_cursor_shape() != Input.CURSOR_ARROW: return
	self.visible = my_visible
	if my_visible and global_loc != Vector2.INF:
		self.set_deferred("global_position", global_loc)


func _on_hide() -> void:
	self.visible = false
