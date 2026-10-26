extends CharacterBody2D
class_name Actor

enum ACTOR_STATE { IDLE, MOVING }
var __current_actor_state: ACTOR_STATE = ACTOR_STATE.IDLE

@export var display_name: String = "[Actor]"
@export var owner_group: Statics.GROUPS = Statics.GROUPS.PLAYER_ACTORS

var current_integrity: float = 1.2
var max_movement_distance: float = 8.0


var __movement_coords: Array[Vector2] = []
var __movement_destination: Vector2 = Vector2.INF


func _physics_process(delta: float) -> void:
	match __current_actor_state:
		ACTOR_STATE.MOVING:
			if __movement_destination == Vector2.INF:
				if __movement_coords.size() > 0:
					__movement_destination = __movement_coords.pop_back()
				else:
					__stop_movement()
					return
			elif __has_reached_current_destination():
				if __movement_coords.size() > 0:
					__movement_destination = __movement_coords.pop_back()
				else:
					__stop_movement()
					return
			__move_towards_destination(delta)


func __has_reached_current_destination() -> bool:
	return self.global_position.distance_to(__movement_destination) < Statics.REACHED_DESTINATION_THRESHOLD


func __move_towards_destination(delta: float) -> void:
	var distance: float = self.global_position.distance_to(__movement_destination)
	var max_speed: float = distance / delta
	var movement: Vector2 = min(Statics.MOVEMENT_SPEED, max_speed) \
		* self.global_position.direction_to(__movement_destination) \
		* delta
		
	var collision = move_and_collide(movement)
	
	if collision:
		__stop_movement()
	
	self.velocity = Vector2.ZERO


func do_movement(coords: Array[Vector2]) -> void:
	SignalManager.on_object_selection_cleared.emit()
	__movement_coords = coords
	# lock camera to me
	SignalManager.on_start_camera_follow.emit(self)
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	set_deferred("__current_actor_state", ACTOR_STATE.MOVING)
	

func remove_activation_circle() -> void:
	$ActivationCircleSprite.visible = false


func __stop_movement() -> void:
	SignalManager.on_stop_camera_follow.emit()
	__current_actor_state = ACTOR_STATE.IDLE
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	GameStateManager.handle_player_movement_complete()


func __mouse_actions_enabled() -> bool:
	match GameStateManager.current_game_state:
		GameStateManager.GAME_STATE.PLAYER_IDLE, GameStateManager.GAME_STATE.PLAYER_ACTOR_ACTIVATED:
			return true
		_:
			return false


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if __mouse_actions_enabled():
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			if GameStateManager.selected_actor == self:
				GameStateManager.try_activate_actor(self)
				$ActivationCircleSprite.visible = true
			else:
				SignalManager.on_print_message_to_log.emit("%s clicked" % display_name)
				SignalManager.on_object_selected.emit(self)


func _on_mouse_entered() -> void:
	if __mouse_actions_enabled():
		SignalManager.on_move_hover_circle.emit(true, self.global_position)


func _on_mouse_exited() -> void:
	if __mouse_actions_enabled():
		SignalManager.on_move_hover_circle.emit(false, Vector2.INF)
