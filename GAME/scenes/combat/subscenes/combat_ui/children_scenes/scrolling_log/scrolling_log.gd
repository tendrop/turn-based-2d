extends PanelContainer
class_name ScrollingLog


const MAX_MESSAGES: int = 30


func _ready() -> void:
	SignalManager.on_print_message_to_log.connect(_on_print_message_to_log)
	%RichTextLabel.text = ">> Interdiction initiated. Happy hacking, Reclaimer 2828." + "\n"
	

func _on_print_message_to_log(new_msg: String, msg_type: Statics.MSG_TYPE) -> void:
	match msg_type:
		Statics.MSG_TYPE.WARN:
			%RichTextLabel.push_color(Statics.ColorDict[Statics.COLORS.YELLOW])
		_:
			%RichTextLabel.push_color(Statics.ColorDict[Statics.COLORS.GRAY_33])

	%RichTextLabel.append_text(">> " + new_msg + "\n")
	%RichTextLabel.pop()
	if %RichTextLabel.get_paragraph_count() > MAX_MESSAGES:
		%RichTextLabel.remove_paragraph(0)
