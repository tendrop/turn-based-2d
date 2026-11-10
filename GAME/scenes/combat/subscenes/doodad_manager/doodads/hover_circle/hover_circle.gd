extends Sprite2D
class_name HoverCircle


func _ready() -> void:
	SignalManager.on_move_hover_circle.connect(_on_move_hover_circle)
	SignalManager.on_object_selection_cleared.connect(_on_hide)


func _on_move_hover_circle(my_visible: bool, global_loc: Vector2) -> void:
	if Input.get_current_cursor_shape() != Input.CURSOR_ARROW: return
	if my_visible:
		self.visible = true
		self.global_position = global_loc
	else:
		# only hide if it's being called by same thing that made it show
		# up in the first place
		if global_loc == self.global_position:
			self.visible = false


func _on_hide() -> void:
	self.visible = false
