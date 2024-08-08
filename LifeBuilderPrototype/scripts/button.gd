extends Button

func _on_Button_pressed():
	grab_focus()

func _on_Button_button_up():
	release_focus()

func _ready():
	self.button_down.connect(_on_Button_pressed)
	self.button_up.connect(_on_Button_button_up)
