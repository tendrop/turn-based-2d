extends Tree
class_name PlayerActorsTable

enum COLS {
	ACTR,
	TYPE,
	INTG, 
	STATE
}

# actor names will be [type]_##
const __columns: Dictionary[COLS, int] = {
	COLS.ACTR: 0,
	COLS.INTG: 1,
	COLS.STATE: 2
}


var __player_actors: Dictionary[Actor, TreeItem] = {}


func _ready():
	SignalManager.on_object_selected.connect(_on_object_selected)
	SignalManager.on_object_selection_cleared.connect(_on_object_selection_cleared)
	SignalManager.on_select_next_player_actor.connect(_on_select_next_player_actor)
	
	for col_name: COLS in __columns.keys():
		set_column_title(__columns[col_name], COLS.keys()[col_name])
	
	set_column_title_alignment(0, HORIZONTAL_ALIGNMENT_LEFT)
	set_column_custom_minimum_width(__columns[COLS.ACTR], 70)
	set_column_custom_minimum_width(__columns[COLS.INTG], 40)
	
	# state column (shows buff/debuff icons) will be small then expand
	set_column_custom_minimum_width(__columns[COLS.STATE], 40)
	set_column_expand(__columns[COLS.STATE], true)
	
	var root: TreeItem = create_item()
	
	for a: Actor in get_tree().get_nodes_in_group("player_actors"):
		var tree_item: TreeItem = create_item(root)
		tree_item.set_text(__columns[COLS.ACTR], a.display_name)
		tree_item.set_text(__columns[COLS.INTG], str(round(a.current_integrity)))
		#tree_item.set_cell_mode(__columns[COLS.STATE], TreeItem.CELL_MODE_ICON)
		#tree_item.set_icon_modulate(__columns[COLS.LOCK], Statics.ColorDict[Statics.COLORS.YELLOW])
		
		__player_actors[a] = tree_item
		#a.on_gear_changed.connect(_on_actor_gear_changed)
		#a.on_lock_changed.connect(_on_actor_lock_changed)
		#a.on_integrity_changed.connect(_on_actor_integrity_changed)
		#a.on_death.connect(_on_actor_death)
		
	 # center-align all but first column
	for i: int in range(1, __columns.values().max() + 1):
		get_root().call_recursive("set_text_alignment", i, HORIZONTAL_ALIGNMENT_CENTER)


func _on_object_selected(n: Node2D) -> void:
	if n is Actor and __player_actors.has(n):
		var tree_item: TreeItem = __player_actors[n as Actor]
		if not tree_item.is_selected(0):
			tree_item.select(0)
	else:
		self.deselect_all()


func _on_select_next_player_actor() -> void:
	print("signal heard")
	var tree_item: TreeItem = self.get_selected()
	if tree_item:
		# find index of current entry
		var index: int = 0
		for item: TreeItem in __player_actors.values():
			index += 1
			if item == tree_item:
				break
		
		if index > __player_actors.size() - 1:
			index = 0
		
		var actor: Actor = __player_actors.keys()[index]
		__player_actors[actor].select(0)
		SignalManager.on_object_selected.emit(actor)
		
	else:
		# select first entry if nothing is selected
		__player_actors[__player_actors.keys()[0]].select(0)
		SignalManager.on_object_selected.emit(__player_actors.keys()[0])


func _on_object_selection_cleared() -> void:
	self.deselect_all()
