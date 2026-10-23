extends Node2D
class_name Movement_Plotter


const MOVEMENT_PLOT_MARKER = preload("uid://qk15eo4ekh33")

var __actor: Actor = null
var __local_starting_pos: Vector2 = Vector2.ZERO

var __saved_line_coords: Array[Vector2] = []
var __saved_line_color: Color = Statics.ColorDict[Statics.COLORS.GRAY_50]
var __plot_markers: Array[MovementPlotMarker] = []

var __disable_further_mvmt: bool = false

func _ready() -> void:
	SignalManager.on_start_player_movement_plotting.connect(_on_start_player_movement_plotting)
	SignalManager.on_stop_player_movement_plotting.connect(_on_stop_player_movement_plotting)
	SignalManager.on_world_left_clicked.connect(_on_world_left_clicked)
	SignalManager.on_try_remove_movement_pivot_point.connect(_on_try_remove_movement_pivot_point)
	self.set_process(false)


func _process(_delta: float) -> void:
	self.queue_redraw()
	__check_for_contact_points()


func _draw() -> void:
	if __actor:
		## note: change z-axis of this node to change line's z-axis
		# https://docs.godotengine.org/en/stable/tutorials/2d/custom_drawing_in_2d.html

		## all previous connected lines are white, b/c we know they are valid
		if __saved_line_coords.size() > 1:
			draw_polyline(
				#__saved_line_coords + [to_local(get_global_mouse_position())],
				__saved_line_coords,
				Color.WHITE,
				2.0,
				true
			)
		
		## newest line based on updated color
		draw_line(
			__saved_line_coords.back(),
			to_local(get_global_mouse_position()),
			__saved_line_color,
			2.0,
			true
		)
		
	else:
		self.set_process(false)


func _on_world_left_clicked() -> void:
	if __actor == null or __disable_further_mvmt: return
	
	var new_pos: Vector2 = Vector2.INF
	
	# if we have a contact point from raycast collision, 
	#  we just put point there
	if %RayCast.is_colliding():
		var used_distance: float = __get_total_distance(true)
		
		var collision_distance: float = %RayCast.global_position.distance_to(
			%RayCast.get_collision_point()) / Statics.PIXELS_TO_UNITS_CONVERSION
		
		if used_distance + collision_distance > __actor.max_movement_distance:
			# stop before the collision point
			var remaining_dist: float = __actor.max_movement_distance - used_distance
			remaining_dist = snapped(remaining_dist, 0.1)
			if remaining_dist > 0:
				var remaining_pixels: float = remaining_dist * Statics.PIXELS_TO_UNITS_CONVERSION
				var start_pos: Vector2 = __saved_line_coords.back()
				var end_pos: Vector2 = %ContactPoint.position
				var direction: Vector2 = (end_pos - start_pos).normalized()
				new_pos = start_pos + (direction * remaining_pixels)
		else:
			# stop at contact point
			new_pos = %ContactPoint.position
			__disable_further_mvmt = true
	else:
		# check distance
		var total_dist: float = __get_total_distance(false)
		if total_dist <= __actor.max_movement_distance:
			new_pos = to_local(get_global_mouse_position())
		else:
			# put line at max possible distance
			var remaining_dist: float = __actor.max_movement_distance - __get_total_distance(true)
			remaining_dist = snapped(remaining_dist, 0.1)
			if remaining_dist == 0:
				SignalManager.on_print_message_to_log.emit("Max Distance Exceeded; Cannot plot course.")
				return
			
			var remaining_pixels: float = remaining_dist * Statics.PIXELS_TO_UNITS_CONVERSION
			var start_pos: Vector2 = __saved_line_coords.back()
			var end_pos: Vector2 = to_local(get_global_mouse_position())
			var direction: Vector2 = (end_pos - start_pos).normalized()
			new_pos = start_pos + (direction * remaining_pixels)
	
	# if we have a position, add it
	if not new_pos == Vector2.INF:
		__saved_line_coords.append(new_pos)
		%RayCast.position = new_pos
		var marker: MovementPlotMarker = MOVEMENT_PLOT_MARKER.instantiate()
		marker.position = new_pos
		__plot_markers.append(marker)
		add_child(marker)


func _on_start_player_movement_plotting(a: Actor) -> void:
	__disable_further_mvmt = false
	__local_starting_pos = to_local(a.global_position)
	__actor = a
	__saved_line_coords = [ __local_starting_pos ]
	%RayCast.global_position = a.global_position
	__plot_markers = []
	%RayCast.enabled = true
	self.set_process(true)
	$UiUpdateTimer.start()


func _on_stop_player_movement_plotting() -> void:
	__actor = null
	%RayCast.enabled = true
	%ContactPoint.visible = false
	$UiUpdateTimer.stop()
	self.set_process(false)


func _on_try_remove_movement_pivot_point() -> void:
	if __saved_line_coords.size() > 1:
		__saved_line_coords.pop_back()
		var marker: MovementPlotMarker = __plot_markers.pop_back()
		if marker:
			marker.queue_free()
		__disable_further_mvmt = false
		%RayCast.position = __saved_line_coords[__saved_line_coords.size() - 1]


func __get_total_distance(ignore_current_mouse_pos: bool) -> float:
	var total_dist: float = 0.0
	for i in __saved_line_coords.size() - 1:
		total_dist += __saved_line_coords[i].distance_to(__saved_line_coords[i + 1])
	
	if not ignore_current_mouse_pos:
		total_dist += __saved_line_coords[__saved_line_coords.size() - 1].distance_to(to_local(get_global_mouse_position()))
	
	total_dist /= Statics.PIXELS_TO_UNITS_CONVERSION
	
	return total_dist


func __check_for_contact_points() -> void:
	# raycast from origin to mouse point
	%RayCast.target_position = %RayCast.to_local(get_global_mouse_position())
	%RayCast.force_raycast_update()
	if %RayCast.is_colliding():
		%ContactPoint.global_position = $%RayCast.get_collision_point()
		%ContactPoint.visible = true
	else:
		%ContactPoint.visible = false


func _on_ui_update_timer_timeout() -> void:
	var total_dist: float = __get_total_distance(false)
	
	if total_dist > __actor.max_movement_distance:
		__saved_line_color = Statics.ColorDict[Statics.COLORS.YELLOW]
	else:
		__saved_line_color = Statics.ColorDict[Statics.COLORS.GRAY_50]
	
	SignalManager.on_update_player_movement_distance.emit(total_dist)
