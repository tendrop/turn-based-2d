extends PanelContainer
class_name PlayerMovementPanel


func _ready() -> void:
	SignalManager.on_start_player_movement_plotting.connect(_on_start_player_movement_plotting)
	SignalManager.on_stop_player_movement_plotting.connect(_on_stop_player_movement_plotting)
	SignalManager.on_update_player_movement_distance.connect(_on_update_player_movement_distance)


func _on_start_player_movement_plotting(my_actor: Actor) -> void:
	self.visible = true
	#Input.warp_mouse(get_viewport().get_canvas_transform() * my_actor.global_position)
	get_viewport().warp_mouse(my_actor.get_global_transform_with_canvas().origin)
	Input.set_default_cursor_shape(Input.CURSOR_CROSS)


func _on_stop_player_movement_plotting() -> void:
	self.visible = false
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _on_update_player_movement_distance(dist: float) -> void:
	%DistanceTraveled.text = "Total Distance: %.1f U" % dist 
