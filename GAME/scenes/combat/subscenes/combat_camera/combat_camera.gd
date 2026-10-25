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

var __following: Node2D = null


func _ready() -> void:
	__target_zoom = self.zoom
	SignalManager.on_start_camera_follow.connect(_on_start_camera_follow)
	SignalManager.on_stop_camera_follow.connect(_on_stop_camera_follow)


func _process(delta: float) -> void:
	self.zoom = self.zoom.lerp(__target_zoom, 1.0 - exp(-ZOOM_SPEED * delta))
	if is_instance_valid(__following) and __following:
		#self.global_position = self.global_position.move_toward(__following.global_position, 100 * delta)
		self.global_position = self.global_position.lerp(__following.global_position, 1.0 - pow(0.5, delta))

func _on_start_camera_follow(n: Node2D) -> void:
	__following = n

func _on_stop_camera_follow() -> void:
	__following = null

func _unhandled_input(event: InputEvent) -> void:
	if is_instance_valid(__following) and __following:
		return 
	
	# hold right-click to pan camera
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			__is_panning = true
			Input.set_default_cursor_shape(Input.CURSOR_MOVE)
			get_viewport().set_input_as_handled()
		else:
			__is_panning = false
			Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	elif event is InputEventMouseMotion and __is_panning:
		position += -event.relative / zoom
		get_viewport().set_input_as_handled()
	
	# zoom with mouse wheel
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			__do_zoom(true)
			get_viewport().set_input_as_handled()
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
	
