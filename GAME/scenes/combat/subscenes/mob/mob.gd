extends CharacterBody2D
class_name Mob

signal on_task_finished

@export var display_name: String = "[Mob]"
@export var owner_group: Statics.GROUPS = Statics.GROUPS.ENEMY_MOBS
@export var max_movement_units: float = 8.0


enum MOBSTATE { IDLE,  MOVING }
var current_mobstate: MOBSTATE = MOBSTATE.IDLE

var target: Node2D = null

@onready var mob_sprite: Sprite2D = %MobSprite


func _ready() -> void:
	%Movement.setup(self, $MobNavAgent, max_movement_units)
	## IF AVOIDANCE in NavAgent IS ENAABLED (Which it is not right now), then need to use _on_velocity_computed
	#$MobNavAgent.velocity_computed.connect(_on_velocity_computed)
	#SignalManager.on_world_rebake_complete.connect(_world_ready_for_movement)

func _physics_process(_delta: float) -> void:
	match current_mobstate:
		MOBSTATE.MOVING:
			if Statics.has_reached_current_destination(self.global_position, target.global_position):
				__task_finished()
			else:
				%Movement.continue_move()


func do_task(my_task: Statics.ENEMY_TASK, my_target: Node2D) -> void:
	self.target = my_target
	match my_task:
		Statics.ENEMY_TASK.MOVE:
			%Movement.prepare_movement(my_target)
			#__travelled_pixels = 0
			#__last_position = self.global_position
			#$MobNavAgent.target_position = target.global_position
			#current_mobstate = MOBSTATE.WAITING_FOR_WORLD_REBAKE
			#SignalManager.on_rebake_world.emit(self)
			# _world_ready_for_movement will be emitted when rebake is done,
			#  which will change to MOVING state
			#current_mobstate = MOBSTATE.MOVING


#func _world_ready_for_movement() -> void:
	#if current_mobstate == MOBSTATE.WAITING_FOR_WORLD_REBAKE:
		## baked world is availble on next physics frame, so need to defer
		#set_deferred("current_mobstate", MOBSTATE.MOVING)


## called by PrimaryCombat.WorldNavigation before baking
func toggle_is_obstacle(is_obstacle: bool) -> void:
	$NavigationObstacle2D.affect_navigation_mesh = is_obstacle


func __task_finished() -> void:
	current_mobstate = MOBSTATE.IDLE
	on_task_finished.emit()


#func __continue_move() -> void:
	#if $MobNavAgent.is_target_reached():
		#__task_finished()
		#return
	#
	#var new_point_direction: Vector2 = self.global_position.direction_to($MobNavAgent.get_next_path_position())
	#self.velocity = new_point_direction * Statics.MOVEMENT_SPEED
	#move_and_slide()
	## IF AVOIDANCE in NavAgent IS ENAABLED (Which it is not right now), then need to use _on_velocity_computed
	# will move_and_slide when _on_velocity_computed is fired
	#$MobNavAgent.velocity = new_point_direction * Statics.MOVEMENT_SPEED
		

## IF AVOIDANCE in NavAgent IS ENAABLED (Which it is not right now), then need to use _on_velocity_computed
#func _on_velocity_computed(safe_velocity: Vector2) -> void:
	#self.velocity = safe_velocity
	#move_and_slide()


#func __move_towards_target(delta: float) -> void:
	#var frame_dist: float = self.global_position.distance_to(__last_position)
	#__travelled_pixels += frame_dist
	#if __travelled_pixels >= __max_movement_pixels:
		#print("moved to max pixels")
		#__task_finished()
		#return
	#
	#__last_position = self.global_position
	##var direction: Vector2 = self.global_position.direction_to(target.global_position)
	#var direction: Vector2 = %MobContextBasedSteering.steer(target)
	#var movement_velocity: Vector2 = direction * Statics.MOVEMENT_SPEED * delta
	#var collision = move_and_collide(movement_velocity)
	#if collision:
		#__task_finished()
		#return
	#
	#var flip_scale : float = Statics.UNIT_SCALE
	#if direction.x < 0:
		#flip_scale = -flip_scale
	#if %MobSprite.scale.x != flip_scale:
		#%MobSprite.scale.x = flip_scale

###########################################################

func _on_mouse_entered() -> void:
	if Statics.mouse_actions_enabled():
		SignalManager.on_move_hover_circle.emit(true, self.global_position)


func _on_mouse_exited() -> void:
	if Statics.mouse_actions_enabled():
		SignalManager.on_move_hover_circle.emit(false, self.global_position)


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if Statics.mouse_actions_enabled():
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			SignalManager.on_print_message_to_log.emit("%s clicked" % display_name)
			SignalManager.on_object_selected.emit(self)
