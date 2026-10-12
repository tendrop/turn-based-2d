extends Sprite2D
class_name SelectionCircle


func _ready() -> void:
	SignalManager.on_object_selected.connect(_on_object_selected)
	SignalManager.on_object_selection_cleared.connect(_on_object_selection_cleared)


func _on_object_selected(n: Node2D) -> void:
	if n:
		self.visible = true
		self.set_deferred("global_position", n.global_position)
	else:
		self.visible = false


func _on_object_selection_cleared() -> void:
	self.visible = false
		
