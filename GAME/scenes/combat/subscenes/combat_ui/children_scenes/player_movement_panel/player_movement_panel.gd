extends PanelContainer
class_name PlayerMovementPanel

var __max_distance: float

func _ready() -> void:
	SignalManager.on_game_state_changed.connect(_on_game_state_changed)
	SignalManager.on_update_player_movement_distance.connect(_on_update_player_movement_distance)


func _on_game_state_changed(new_state: GameStateManager.GAME_STATE) -> void:
	if new_state == GameStateManager.GAME_STATE.PLAYER_PLOTTING_MOVEMENT:
		_on_start_player_movement_plotting(GameStateManager.activated_actor)
	elif self.visible:
		_on_stop_player_movement_plotting()


func _on_start_player_movement_plotting(my_actor: Actor) -> void:
	__max_distance = my_actor.max_movement_distance
	%DistanceTraveled.text = "Travel Distance: 0.0"
	%MaxDistance.text = "Max Distance: %.1f" % __max_distance
	self.visible = true
	# warp mouse to be at actors position
	#get_viewport().warp_mouse(my_actor.get_global_transform_with_canvas().origin)
	Input.set_default_cursor_shape(Input.CURSOR_CROSS)


func _on_stop_player_movement_plotting() -> void:
	self.visible = false
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)


func _on_update_player_movement_distance(dist: float) -> void:
	%DistanceTraveled.text = "Travel Distance: %.1f" % dist
	if dist > __max_distance:
		%DistanceTraveled.modulate = Statics.ColorDict[Statics.COLORS.YELLOW]
	else:
		%DistanceTraveled.modulate = Color.WHITE
