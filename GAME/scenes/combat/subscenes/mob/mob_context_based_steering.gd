extends Node2D
class_name MobContextBasedSteering

@export var look_ahead_distance: int = 500
const NUMBER_OF_RAYS: int = 24


class SteeringRay:
	var ray_direction: Vector2
	var interest: float
	
	func direction_interest() -> Vector2:
		return ray_direction * interest
		

var __steering_rays: Array[SteeringRay] = []


func _ready() -> void:
	__steering_rays.resize(NUMBER_OF_RAYS)
	for i: int in NUMBER_OF_RAYS:
		var angle = i * 2 * PI / NUMBER_OF_RAYS
		var sr: SteeringRay = SteeringRay.new()
		sr.ray_direction = Vector2.RIGHT.rotated(angle)
		__steering_rays[i] = sr


func steer(current_target: Node2D) -> Vector2:
	var current_direction: Vector2 = self.global_position.direction_to(current_target.global_position)
	if current_direction == Vector2.ZERO:
		return current_direction
	
	var state_space: PhysicsDirectSpaceState2D = self.get_world_2d().direct_space_state
	
	# set interest
	for i: int in NUMBER_OF_RAYS:
		var d: float = __steering_rays[i].ray_direction.dot(current_direction)
		var interest: float = max(0, d)
		
		if interest > 0.0:
			# modify by danger
			var params: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.new()
			params.from = self.global_position
			params.to = self.global_position + __steering_rays[i].ray_direction * self.look_ahead_distance
			params.exclude = [self, current_target]
			var danger = state_space.intersect_ray(params)
			if danger:
				var dist: float = self.global_position.distance_to(danger["position"])
				var danger_amount: float = (self.look_ahead_distance - dist) / self.look_ahead_distance
				interest -= (danger_amount * 1.5)
			
		__steering_rays[i].interest = interest
	
	# finalize direction
	var updated_direction: Vector2 = Vector2.ZERO
	var max_interest: float = 0

	for i: int in NUMBER_OF_RAYS:
		updated_direction += __steering_rays[i].direction_interest()
		if __steering_rays[i].interest > max_interest:
			max_interest = __steering_rays[i].interest
		
	return updated_direction.normalized()
	## reduce throttle if don't have high interest
	#updated_direction = updated_direction.normalized()
	#if max_interest < 0.5:
		#return updated_direction * 0.5
	#elif max_interest < 0.7:
		#return updated_direction * 0.75
	#else:
		#return updated_direction
