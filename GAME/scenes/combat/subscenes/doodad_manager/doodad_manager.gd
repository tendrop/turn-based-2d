extends Node
class_name DoodadManager


func _ready() -> void:
	SignalManager.on_make_movement_plot_marker_doodad.connect($MovementPlotMarkers.make_object)
	
	for i: int in 5:
		$MovementPlotMarkers.generate_new()
