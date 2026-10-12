extends PanelContainer
class_name PlayerExecutionPanel


func _ready() -> void:
	SignalManager.on_object_selected.connect(_on_object_selected)
	SignalManager.on_object_selection_cleared.connect(_on_object_selection_cleared)


func _on_object_selected(n: Node2D) -> void:
	if n is Actor and n.owner_group == Statics.GROUPS.PLAYER_ACTORS:
		# player actor that can take actions is selected
		%T1_ActorName.text = n.display_name
		self.visible = true
		
	else:
		self.visible = false


func _on_object_selection_cleared() -> void:
	self.visible = false
