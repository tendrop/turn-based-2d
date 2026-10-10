extends CanvasLayer
class_name CombatUi


func _ready() -> void:
	SignalManager.on_object_selected.connect(_on_object_selected)



func _on_object_selected(n: Node2D) -> void:
	if "display_name" in n:
		%SelectionLabel.text = n.display_name
