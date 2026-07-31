extends Label

func _ready() -> void:
	Messenger.SHOW_INTERACT_MESSAGE.connect(on_interact_message)
	Messenger.CLEAR_INTERACT_MESSAGE.connect(func(): hide())

func on_interact_message(message: String) -> void:
	if(message==""):
		hide()
	if(text != message):
		text = message
	if(!visible):
		show()
