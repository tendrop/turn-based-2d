extends PanelContainer
class_name PlayerExecutionPanel


func _ready() -> void:
	SignalManager.on_object_selected.connect(_on_object_selected)
	SignalManager.on_object_selection_cleared.connect(_on_object_selection_cleared)
	SignalManager.on_player_actor_activated.connect(_on_player_actor_activated)


func _on_object_selected(_n: Node2D) -> void:
	self.visible = false
func _on_object_selection_cleared() -> void:
	self.visible = false


func _on_player_actor_activated(_actor: Actor) -> void:
	self.visible = true
