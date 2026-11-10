extends CharacterBody2D
class_name Mob

signal on_task_finished

@export var display_name: String = "[Mob]"
@export var owner_group: Statics.GROUPS = Statics.GROUPS.ENEMY_MOBS

enum MOBSTATE { IDLE, MOVING }
var current_mobstate: MOBSTATE = MOBSTATE.IDLE

var target: Node2D = null


func _physics_process(delta: float) -> void:
	match current_mobstate:
		MOBSTATE.MOVING:
			if Statics.has_reached_current_destination(self.global_position, target.global_position):
				__task_finished()
			else:
				__move_towards_target(delta)


func do_task(my_task: Statics.ENEMY_TASK, my_target: Node2D) -> void:
	self.target = my_target
	match my_task:
		Statics.ENEMY_TASK.MOVE:
			current_mobstate = MOBSTATE.MOVING

func __task_finished() -> void:
	current_mobstate = MOBSTATE.IDLE
	on_task_finished.emit()


func __move_towards_target(delta: float) -> void:
	var direction: Vector2 = self.global_position.direction_to(target.global_position)
	var movement_velocity: Vector2 = direction * Statics.MOVEMENT_SPEED * delta
	var collision = move_and_collide(movement_velocity)
	if collision:
		__task_finished()

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
