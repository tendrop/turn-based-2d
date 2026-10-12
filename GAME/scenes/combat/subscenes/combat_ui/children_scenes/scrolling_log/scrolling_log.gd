extends PanelContainer
class_name ScrollingLog


const MAX_MESSAGES: int = 30


func _ready() -> void:
	SignalManager.on_print_message_to_log.connect(_on_print_message_to_log)
	

func _on_print_message_to_log(new_msg: String) -> void:
	%RichTextLabel.append_text(new_msg + "\n")
	if %RichTextLabel.get_paragraph_count() > MAX_MESSAGES:
		%RichTextLabel.remove_paragraph(0)
