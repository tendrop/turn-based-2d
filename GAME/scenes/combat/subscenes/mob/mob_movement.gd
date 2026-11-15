extends Node

var __mob: Mob
var __mvmt_agent: NavigationAgent2D

var __max_movement_pixels: float

var __travelled_pixels: float = 0.0
var __prev_position: Vector2
var __target: Node2D

var __waiting_for_rebake: bool = false
var __stuck_frames: int = 0
const MAX_STUCK_FRAMES: int = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.on_world_rebake_complete.connect(_world_ready_for_movement)


func setup(mob_owner: Mob, mvmt_agent: NavigationAgent2D, max_movement_units: float) -> void:
	__mob = mob_owner
	__mvmt_agent = mvmt_agent
	__max_movement_pixels = max_movement_units * Statics.PIXELS_TO_UNITS_CONVERSION


func prepare_movement(target: Node2D) -> void:
	print("%s preparing new movement" % __mob.display_name)
	__travelled_pixels = 0
	__stuck_frames = 0
	__prev_position = __mob.global_position
	__target = target
	__mvmt_agent.target_position = target.global_position
	__waiting_for_rebake = true
	SignalManager.on_rebake_world.emit(__mob)


func _world_ready_for_movement() -> void:
	if __waiting_for_rebake:
		# baked world is availble on next physics frame, so need to defer
		__waiting_for_rebake = false
		__mob.set_deferred("current_mobstate", __mob.MOBSTATE.MOVING)


func continue_move() -> void:
	# is movement agent done?
	if __mvmt_agent.is_target_reached():
		__mob.__task_finished()
		return
	
	#  have travelled max dist possible?
	var frame_travel_dist: float = __mob.global_position.distance_to(__prev_position)
	__travelled_pixels += frame_travel_dist
	if __travelled_pixels >= __max_movement_pixels:
		print("MOVED MAX PIXELS")
		__mob.__task_finished()
		return
	
	__prev_position = __mob.global_position
		
	var new_point_direction: Vector2 = __mob.global_position.direction_to(__mvmt_agent.get_next_path_position())
	__mob.velocity = new_point_direction * Statics.MOVEMENT_SPEED
	__mob.move_and_slide()
	
	# check for collision
	var last_collision: KinematicCollision2D = null
	for i: int in __mob.get_slide_collision_count():
		last_collision = __mob.get_slide_collision(i)
		var collider: Node2D = last_collision.get_collider()
		if "display_name" in collider:
			print("%s collided with %s (%.6f)" % [__mob.display_name, collider.display_name, frame_travel_dist])
		else:
			print("%s collided with UNKNOWN (%.6f)" % [__mob.display_name, frame_travel_dist])
	
		# track stuck-age
	if last_collision:
		if __mob.velocity.is_zero_approx():
			__mob.__task_finished()
		elif frame_travel_dist < 0.16:
			__stuck_frames += 1
			print("frame %d: %.6f" % [__stuck_frames, frame_travel_dist])
			if __stuck_frames > MAX_STUCK_FRAMES:
				print("STUCK!!!!!!")
				__mob.__task_finished()
		elif __stuck_frames > 0 and frame_travel_dist > 1:
			print("unstuck; resetting stuck frames (%.6f)" % frame_travel_dist)
			__stuck_frames = 0
	
	# flip sprite and its children
	var flip_scale : float = Statics.UNIT_SCALE
	if new_point_direction.x < 0:
		flip_scale = -flip_scale
	if __mob.mob_sprite.scale.x != flip_scale:
		__mob.mob_sprite.scale.x = flip_scale
