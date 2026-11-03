extends Node
class_name EnemyTurnHandler


func _ready() -> void:
	SignalManager.on_start_enemy_turn.connect(_on_start_enemy_turn)
	

func _on_start_enemy_turn() -> void:
	print("ENEMY TURN START")
	$Timer.start()


func _on_timer_timeout() -> void:
	print("ENEMY TURN DONE")
	SignalManager.on_end_enemy_turn.emit()
