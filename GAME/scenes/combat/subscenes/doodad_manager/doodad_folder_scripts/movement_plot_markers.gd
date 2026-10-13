extends Node

const MARKER_DOODAD := preload("uid://qk15eo4ekh33")
var pool: Array[MovementPlotMarker] = []

func generate_new() -> MovementPlotMarker:
	var marker: MovementPlotMarker = MARKER_DOODAD.instantiate()
	marker.on_remove_from_scene.connect(_on_return_to_pool)
	pool.append(marker)
	self.add_child(marker)
	return marker


func make_object(global_pos: Vector2) -> void:
	var marker: MovementPlotMarker
	for m: MovementPlotMarker in pool:
		if !m.active:
			marker = m
			break
	
	if !marker:
		marker = generate_new()
	
	marker.active = true
	call_deferred("__add_to_scene", marker, global_pos)



func _on_return_to_pool(marker: MovementPlotMarker) -> void:
	marker.visible = false
	marker.active = false
