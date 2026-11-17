extends PanelContainer
class_name KeyboardMap


func _ready() -> void:
	SignalManager.on_game_state_changed.connect(_on_game_state_changed)
	#for n: Node in %GridContainer.get_children():
		#if n is KeyboardMapButton:
			#n.set_key_text(n.name.left(1).to_lower())
	#_on_game_state_changed(GameStateManager.GAME_STATE.PLAYER_IDLE)


func _on_game_state_changed(new_state: GameStateManager.GAME_STATE) -> void:
	#__reset_all_keys()
	%KeyboardSetupLabel.text = GameStateManager.GAME_STATE.keys()[new_state]
	#match new_state:
		#GameStateManager.GAME_STATE.PLAYER_IDLE:
			#__idle_state_keys();
		#GameStateManager.GAME_STATE.PLAYER_ACTOR_ACTIVATED:
			#__activated_actor_keys();
		#GameStateManager.GAME_STATE.PLAYER_PLOTTING_MOVEMENT:
			#__plotting_movement_keys();
		#GameStateManager.GAME_STATE.ENEMY_TURN:
			#pass


#func __idle_state_keys():
	#%Q_Button.text = "Cancel"
	#%Q_Button.disabled = false
	#%F_Button.text = "Activate\nActor"
	#%F_Button.disabled = false
#
#
#func __activated_actor_keys():
	#%Q_Button.text = "Cancel"
	#%Q_Button.disabled = false
	#%E_Button.text = "Move"
	#%E_Button.disabled = false
#
#
#func __plotting_movement_keys():
	#%Q_Button.text = "Cancel"
	#%Q_Button.disabled = false
	#%E_Button.text = "Pivot\nPoint"
	#%E_Button.disabled = false
#
#
#func __reset_all_keys() -> void:
	#for n: Node in %GridContainer.get_children():
		#if n is KeyboardMapButton:
			#n.reset_to_default()
