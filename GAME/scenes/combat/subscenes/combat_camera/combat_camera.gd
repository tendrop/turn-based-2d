extends Camera2D
class_name CombatCamera

# for panning
var __is_panning : bool = false

# for zooming
@export var MIN_ZOOM: float = 0.5
@export var MAX_ZOOM: float = 1.0
@export var ZOOM_STEP: float = 0.1
@export var ZOOM_SPEED: float = 10.0
var __target_zoom: Vector2 = Vector2.ONE


func _ready() -> void:
	__target_zoom = self.zoom


func _process(delta: float) -> void:
	self.zoom = self.zoom.lerp(__target_zoom, 1.0 - exp(-ZOOM_SPEED * delta))


func _unhandled_input(event: InputEvent) -> void:
	# hold right-click to pan camera
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			__is_panning = true
			get_viewport().set_input_as_handled()
		else:
			__is_panning = false
	elif event is InputEventMouseMotion and __is_panning:
		position += -event.relative / zoom
		get_viewport().set_input_as_handled()
	
	# zoom with mouse wheel
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			__do_zoom(true)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			__do_zoom(false)
		get_viewport().set_input_as_handled()
		   

func __do_zoom(zoom_in: bool) -> void:
	var zoom_change: float = 1.0
	if zoom_in:
		zoom_change += ZOOM_STEP
	else:
		zoom_change -= ZOOM_STEP
	
	var new_zoom: Vector2 = (self.zoom * zoom_change).clamp(
		Vector2(MIN_ZOOM, MIN_ZOOM), Vector2(MAX_ZOOM, MAX_ZOOM)
	)
	
	if new_zoom != self.zoom:
		__target_zoom = new_zoom
	
