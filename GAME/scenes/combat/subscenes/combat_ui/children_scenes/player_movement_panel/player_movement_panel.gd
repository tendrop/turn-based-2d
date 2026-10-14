extends PanelContainer
class_name PlayerMovementPanel


func _ready() -> void:
	SignalManager.on_start_player_movement_plotting.connect(_on_start_player_movement_plotting)
	SignalManager.on_stop_player_movement_plotting.connect(_on_stop_player_movement_plotting)
	SignalManager.on_update_player_movement_distance.connect(_on_update_player_movement_distance)
	

func _on_start_player_movement_plotting(my_actor: Actor) -> void:
	self.visible = true


func _on_stop_player_movement_plotting() -> void:
	self.visible = false


func _on_update_player_movement_distance(dist: float) -> void:
	%DistanceTraveled.text = "Total Distance: %.1f U" % dist 
