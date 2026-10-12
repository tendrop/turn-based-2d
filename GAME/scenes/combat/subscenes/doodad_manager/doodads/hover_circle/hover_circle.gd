extends Sprite2D
class_name HoverCircle


func _ready() -> void:
	SignalManager.on_move_hover_circle.connect(_on_move_hover_circle)


func _on_move_hover_circle(my_visible: bool, global_loc: Vector2) -> void:
	self.visible = my_visible
	if my_visible and global_loc != Vector2.INF:
		self.set_deferred("global_position", global_loc)
