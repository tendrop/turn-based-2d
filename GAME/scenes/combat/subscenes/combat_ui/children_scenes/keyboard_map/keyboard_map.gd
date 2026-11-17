extends PanelContainer
class_name KeyboardMap


func _ready() -> void:
	for n: Node in %GridContainer.get_children():
		if n is KeyboardMapButton:
			n.set_key_text(n.name.left(1).to_lower())




func __reset_all_keys() -> void:
	for n: Node in %GridContainer.get_children():
		if n is KeyboardMapButton:
			n.reset_to_default()
