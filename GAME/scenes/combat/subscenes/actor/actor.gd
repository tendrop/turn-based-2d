extends CharacterBody2D
class_name Actor

enum ACTOR_STATE { IDLE, MOVING }
var __current_actor_state: ACTOR_STATE = ACTOR_STATE.IDLE

@export var display_name: String = "[Actor]"
@export var owner_group: Statics.GROUPS = Statics.GROUPS.PLAYER_ACTORS

var __knockback_stop_distance: float

var current_integrity: float = 1.2
var max_movement_distance: float = 8.0


var __movement_coords: Array[Vector2] = []
var __movement_destination: Vector2 = Vector2.INF
var __knockback_direction: Vector2
var __collider_global_pos: Vector2


func _physics_process(delta: float) -> void:
	match __current_actor_state:
		ACTOR_STATE.MOVING:
			if __movement_destination == Vector2.INF:
				if __movement_coords.size() > 0:
					__movement_destination = __movement_coords.pop_back()
				else:
					__stop_movement()
					return
			elif __has_reached_current_destination() and __collider_global_pos == Vector2.INF:
				if __movement_coords.size() > 0:
					__movement_destination = __movement_coords.pop_back()
				else:
					__stop_movement()
					return
			__move_towards_destination(delta)


func __has_reached_current_destination() -> bool:
	#print("%0.1f" % self.global_position.distance_to(__movement_destination))
	return self.global_position.distance_to(__movement_destination) <= Statics.REACHED_DESTINATION_THRESHOLD


func __move_towards_destination(delta: float) -> void:
	var movement_velocity: Vector2
	var direction: Vector2
	
	if __collider_global_pos == Vector2.INF:
		# not colliding/knockback-ing
		var distance: float = self.global_position.distance_to(__movement_destination)
		var max_speed: float = distance / delta
		direction = self.global_position.direction_to(__movement_destination)
		movement_velocity = min(Statics.MOVEMENT_SPEED, max_speed) * direction * delta
	else:
		# knocking back; check distance first
		var knock_dist: float = self.global_position.distance_to(__collider_global_pos)
		if knock_dist >= __knockback_stop_distance:
			__stop_movement()
			return
		else:
			movement_velocity = __knockback_direction * Statics.MOVEMENT_SPEED * delta
		
	
	var collision = move_and_collide(movement_velocity)
	
	if collision:
		if __knockback_direction == Vector2.INF:
			var obj: Object = collision.get_collider()
			if obj is Actor:
				__knockback_stop_distance = self.global_position.distance_to(obj.global_position) + 10
				__collider_global_pos = obj.global_position
				__knockback_direction = -direction
			else:
				__stop_movement()
		else:
			# shouldn't have a second collision b/c just on return path.
			# but, if do, then just stop
			push_error("uh-oh: actor collided with something again post-collision")
			__stop_movement()
	
	var flip_scale : float = 0.5
	if direction.x < 0:
		flip_scale = -0.5
	if %ActorSprite.scale.x != flip_scale:
		%ActorSprite.scale.x = flip_scale
	
	self.velocity = Vector2.ZERO


func do_movement(coords: Array[Vector2]) -> void:
	SignalManager.on_object_selection_cleared.emit()
	__movement_coords = coords
	__movement_destination = Vector2.INF
	__collider_global_pos = Vector2.INF
	__knockback_direction = Vector2.INF
	# lock camera to me
	SignalManager.on_move_camera.emit(self.global_position)
	#SignalManager.on_start_camera_follow.emit(self)
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	__current_actor_state = ACTOR_STATE.MOVING
	

func remove_activation_circle() -> void:
	$ActivationCircleSprite.visible = false


func __stop_movement() -> void:
	#SignalManager.on_stop_camera_follow.emit()
	__current_actor_state = ACTOR_STATE.IDLE
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	GameStateManager.handle_player_actor_task_complete()


func __mouse_actions_enabled() -> bool:
	match GameStateManager.current_game_state:
		GameStateManager.GAME_STATE.PLAYER_IDLE, GameStateManager.GAME_STATE.PLAYER_ACTOR_ACTIVATED:
			return true
		_:
			return false


func activate_me() -> void:
	GameStateManager.try_activate_actor(self)
	if GameStateManager.activated_actor == self:
		$ActivationCircleSprite.visible = true


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if __mouse_actions_enabled():
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			if GameStateManager.selected_actor == self:
				activate_me()
			else:
				SignalManager.on_print_message_to_log.emit("%s clicked" % display_name)
				SignalManager.on_object_selected.emit(self)


func _on_mouse_entered() -> void:
	if __mouse_actions_enabled():
		SignalManager.on_move_hover_circle.emit(true, self.global_position)


func _on_mouse_exited() -> void:
	if __mouse_actions_enabled():
		SignalManager.on_move_hover_circle.emit(false, Vector2.INF)
