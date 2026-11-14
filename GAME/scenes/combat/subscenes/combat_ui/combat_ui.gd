extends CanvasLayer
class_name CombatUi


func _ready() -> void:
	SignalManager.on_object_selected.connect(_on_object_selected)
	SignalManager.on_object_selection_cleared.connect(_on_object_selection_cleared)
	SignalManager.on_start_enemy_turn.connect(_on_start_enemy_turn)
	SignalManager.on_end_enemy_turn.connect(_on_end_enemy_turn)


func _on_object_selected(n: Node2D) -> void:
	if "display_name" in n:
		%SelectionLabel.text = n.display_name
		%SelectionInfoContainer.visible = true
	else:
		%SelectionInfoContainer.visible = false


func _on_object_selection_cleared() -> void:
	%SelectionInfoContainer.visible = false


func _on_start_enemy_turn(_number_of_actions: int) -> void:
	%TurnBanner.visible = true


func _on_end_enemy_turn() -> void:
	%TurnBanner.visible = false
