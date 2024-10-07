extends Control

@onready var select_menu = $SelectMenu
@onready var collapse_menu : CollapsibleContainer = select_menu.get_child(0)
@onready var content = collapse_menu.get_child(0)

@onready var horizontal_box : HBoxContainer = $SelectMenu/CollapsibleContainer/HBoxContainer

func _ready():

	collapse_menu.custom_open_size = Vector2(get_viewport_rect().size.x, get_viewport_rect().size.y * (2.0/9.0))

	#@onready var collapse_left_1 : CollapsibleContainer = $SelectMenu/CollapsibleContainer/HBoxContainer/MarginContainer/VBoxContainer/SelectMenu2/CollapsibleContainer2
	#@onready var collapse_left_2 : CollapsibleContainer = $SelectMenu/CollapsibleContainer/HBoxContainer/MarginContainer/VBoxContainer/SelectMenu3/CollapsibleContainer2
	#collapse_left_1.custom_open_size = Vector2(collapse_left_1.get_parent().size.x/3, collapse_left_1.get_parent().size.y)
	#collapse_left_2.custom_open_size = Vector2(collapse_left_1.get_parent().size.x/3, collapse_left_1.get_parent().size.y)
	#collapse_left_1.custom_close_size = Vector2(collapse_left_1.get_parent().size.x/20, collapse_left_1.get_parent().size.y)
	#collapse_left_2.custom_close_size = Vector2(collapse_left_1.get_parent().size.x/20, collapse_left_1.get_parent().size.y)

	horizontal_box.get_child(0).custom_minimum_size = Vector2(get_viewport_rect().size.x * (1.0/9.0), get_viewport_rect().size.y)
	horizontal_box.get_child(1).custom_minimum_size = Vector2(get_viewport_rect().size.x * (4.0/9.0), get_viewport_rect().size.y)
	horizontal_box.get_child(2).custom_minimum_size = Vector2(get_viewport_rect().size.x * (2.0/9.0), get_viewport_rect().size.y)
	horizontal_box.get_child(3).custom_minimum_size = Vector2(get_viewport_rect().size.x * (2.0/9.0), get_viewport_rect().size.y)

	collapse_menu.open()
	#collapse_left_1.open()
	#collapse_left_2.open()

	#collapse_left_1.get_child(0).connect("mouse_entered", toggle_left_1)
	#collapse_left_1.get_child(0).connect("mouse_exited", toggle_left_1)
	#collapse_left_2.get_child(0).connect("mouse_entered", toggle_left_2)
	#collapse_left_2.get_child(0).connect("mouse_exited", toggle_left_2)

func _process(_delta):
	if Input.is_action_just_pressed("tab"):
		menu_toggle()
	if Input.is_action_just_pressed("interact"):
		toggle_left_1()
		toggle_left_2()

func menu_toggle():
	collapse_menu.open_tween_toggle.call_deferred()

func toggle_left_1():
	pass#collapse_left_1.open_tween_toggle.call_deferred()

func toggle_left_2():
	pass#collapse_left_2.open_tween_toggle.call_deferred()
