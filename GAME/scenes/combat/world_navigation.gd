extends NavigationRegion2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.on_rebake_world.connect(_rebake_world_navigation)


func _rebake_world_navigation(moving_mob: Mob) -> void:
	for n: Node in get_tree().get_nodes_in_group("enemy_mobs"):
		if n is Mob:
			n.toggle_is_obstacle(moving_mob != n)
	self.bake_navigation_polygon(true)
	await self.bake_finished
	SignalManager.on_world_rebake_complete.emit() 
	
	
#func rebuild_and_bake(region: NavigationRegion2D):
	#var poly := NavigationPolygon.new()
	#poly.agent_radius = 10.0
#
	## Add your traversable outline(s)
	#poly.add_outline(PackedVector2Array([
		#Vector2(0, 0), Vector2(1000, 0),
		#Vector2(1000, 1000), Vector2(0, 1000)
	#]))
	## Add obstacle outlines (holes)
	## poly.add_outline(PackedVector2Array([...]))
#
	#poly.make_polygons_from_outlines()
	#region.navigation_polygon = poly
	#region.bake_navigation_polygon(true)
	#await region.bake_finished
