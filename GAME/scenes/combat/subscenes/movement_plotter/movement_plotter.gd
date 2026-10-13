extends Node2D
class_name Movement_Plotter

var __actor: Actor = null
var __local_starting_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	SignalManager.on_start_player_movement_plotting.connect(_on_start_player_movement_plotting)
	SignalManager.on_stop_player_movement_plotting.connect(_on_stop_player_movement_plotting)
	self.set_process(false)


func _process(_delta: float) -> void:
	self.queue_redraw()


func _draw() -> void:
	if __actor:
		## note: change z-axis of node to change line's z-axis
		# https://docs.godotengine.org/en/stable/tutorials/2d/custom_drawing_in_2d.html
		#  probably want draw_polyline instad for long connected line
		draw_line(
			__local_starting_pos,
			to_local(get_global_mouse_position()),
			Color.WHITE,
			2.0,
			true
		)
	else:
		self.set_process(false)



func _on_start_player_movement_plotting(a: Actor) -> void:
	__local_starting_pos = to_local(a.global_position)
	__actor = a
	self.set_process(true)


func _on_stop_player_movement_plotting() -> void:
	__actor = null
	self.set_process(false)
