extends Node2D
class_name Movement_Plotter

var __actor: Actor = null
var __local_starting_pos: Vector2 = Vector2.ZERO

var __saved_line_coords: Array[Vector2] = []

func _ready() -> void:
	SignalManager.on_start_player_movement_plotting.connect(_on_start_player_movement_plotting)
	SignalManager.on_stop_player_movement_plotting.connect(_on_stop_player_movement_plotting)
	SignalManager.on_world_left_clicked.connect(_on_world_left_clicked)
	SignalManager.on_try_remove_movement_pivot_point.connect(_on_try_remove_movement_pivot_point)
	self.set_process(false)


func _process(_delta: float) -> void:
	self.queue_redraw()


func _draw() -> void:
	if __actor:
		## note: change z-axis of this node to change line's z-axis
		# https://docs.godotengine.org/en/stable/tutorials/2d/custom_drawing_in_2d.html
		#  probably want draw_polyline instad for long connected line
		#draw_line(
			#__local_starting_pos,
			#to_local(get_global_mouse_position()),
			#Color.WHITE,
			#2.0,
			#true
		#)
		
		draw_polyline(
			__saved_line_coords + [to_local(get_global_mouse_position())],
			Color.WHITE,
			2.0,
			true
		)
	else:
		self.set_process(false)


func _on_world_left_clicked() -> void:
	if __actor != null:
		__saved_line_coords.append(to_local(get_global_mouse_position()))


func _on_start_player_movement_plotting(a: Actor) -> void:
	__local_starting_pos = to_local(a.global_position)
	__actor = a
	__saved_line_coords = [ __local_starting_pos ]
	self.set_process(true)
	$UiUpdateTimer.start()


func _on_stop_player_movement_plotting() -> void:
	__actor = null
	$UiUpdateTimer.stop()
	self.set_process(false)


func _on_try_remove_movement_pivot_point() -> void:
	if __saved_line_coords.size() > 1:
		__saved_line_coords.pop_back()


func _on_ui_update_timer_timeout() -> void:
	var total_dist: float = 0.0
	for i in __saved_line_coords.size() - 1:
		total_dist += __saved_line_coords[i].distance_to(__saved_line_coords[i + 1])
		
	total_dist += __saved_line_coords[__saved_line_coords.size() - 1].distance_to(to_local(get_global_mouse_position()))
	
	SignalManager.on_update_player_movement_distance.emit(total_dist / Statics.PIXELS_TO_UNITS_CONVERSION)
