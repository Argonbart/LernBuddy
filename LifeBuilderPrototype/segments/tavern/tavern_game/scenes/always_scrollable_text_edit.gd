extends TextEdit

#func _process(_delta):
	#if Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_UP):
		#print("a")
		#scroll_vertical += 10
	#if Input.is_action_pressed("mouse down"):
		#print("b")
		#scroll_vertical -= 10
#
#func _gui_input(event: InputEvent) -> void:
	#if event is InputEventMouseButton:
		#print("c")
