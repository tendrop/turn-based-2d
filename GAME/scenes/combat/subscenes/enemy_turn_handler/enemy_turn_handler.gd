extends Node
class_name EnemyTurnHandler


func _ready() -> void:
	SignalManager.on_start_enemy_turn.connect(_on_start_enemy_turn)
	

func _on_start_enemy_turn(number_of_actions: int) -> void:
	print("ENEMY TURN START")
	
	var mobs: Array[Mob] = []
	
	for n: Node in get_tree().get_nodes_in_group("enemy_mobs"):
		if n is Mob:
			mobs.append(n)
	
	if mobs.size() == 0:
		push_error("EnemyTurnHandler._on_start_enemy_turn did not find any enemies")
		return
	
	for i_loop: int in range(number_of_actions):
		## remove dead mobs
		for i_mob: int in range(mobs.size()):
			if not is_instance_valid(mobs[i_mob]):
				mobs.remove_at(i_mob)
		
		if mobs.size() == 0:
			push_warning("All mobs are gone")
			enemy_turn_complete()
			return
		
		## randomly pick an enemy mob (for now)
		var mob: Mob = mobs.pick_random()
		
		var task_count: int = 1
		while task_count < 3:
			## pick a task (movement only for now)
			var task: Statics.ENEMY_TASK = Statics.ENEMY_TASK.MOVE
			var target: Node2D = null
			
			# TODO: if infiltrate, then add to task_count here
			match task:
				Statics.ENEMY_TASK.MOVE:
					target = get_tree().get_nodes_in_group("player_actors")[0]
			
			## tell mob to do the task
			SignalManager.on_print_message_to_log.emit(
				"%s Task #%d: %s" % [
					mob.display_name, task_count, Statics.ENEMY_TASK.keys()[task]
				]
			)

			mob.do_task(task, target)
			await mob.on_task_finished
			task_count += 1
	
	enemy_turn_complete()


func enemy_turn_complete() -> void:
	print("ENEMY TURN DONE")
	SignalManager.on_end_enemy_turn.emit()
