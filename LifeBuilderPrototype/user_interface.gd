extends Control

@onready var select_menu = $MCSelectMenu
@onready var collapse_menu : CollapsibleContainer = select_menu.get_child(0)
@onready var bottom_hbox : HBoxContainer = select_menu.get_child(0).get_child(0).get_child(1)
@onready var upper_hbox : HBoxContainer = select_menu.get_child(0).get_child(0).get_child(0)
@onready var left_selection_vbox : VBoxContainer = select_menu.get_child(0).get_child(0).get_child(1).get_child(0).get_child(0)
@onready var up_selection_hbox : HBoxContainer = select_menu.get_child(0).get_child(0).get_child(0).get_child(1)
@onready var submenu_list = select_menu.get_child(0).get_child(0).get_child(1).get_child(1).get_children()
@onready var hexagon_field = $"../../HexagonController"

var active_menu = null
var toggle_index_left = 0
var toggle_index_up = 0

func _ready():
	
	# select menu spacing
	collapse_menu.custom_open_size = Vector2(get_viewport_rect().size.x, get_viewport_rect().size.y * (3.0/9.0))
	collapse_menu.open()
	
	# bottom area spacing
	bottom_hbox.get_child(0).custom_minimum_size = Vector2(get_viewport_rect().size.x * (1.0/9.0), get_viewport_rect().size.y * (2.0/9.0))
	bottom_hbox.get_child(1).custom_minimum_size = Vector2(get_viewport_rect().size.x * (4.0/9.0), get_viewport_rect().size.y * (2.0/9.0))
	bottom_hbox.get_child(2).custom_minimum_size = Vector2(get_viewport_rect().size.x * (2.0/9.0), get_viewport_rect().size.y * (2.0/9.0))
	bottom_hbox.get_child(3).custom_minimum_size = Vector2(get_viewport_rect().size.x * (2.0/9.0), get_viewport_rect().size.y * (2.0/9.0))
	
	# upper area spacing
	upper_hbox.get_child(0).custom_minimum_size = Vector2(get_viewport_rect().size.x * (1.0/9.0), get_viewport_rect().size.y * (1.0/9.0))
	upper_hbox.get_child(1).custom_minimum_size = Vector2(get_viewport_rect().size.x * (4.0/9.0), get_viewport_rect().size.y * (1.0/9.0))
	upper_hbox.get_child(2).custom_minimum_size = Vector2(get_viewport_rect().size.x * (2.0/9.0), get_viewport_rect().size.y * (1.0/9.0))
	upper_hbox.get_child(3).custom_minimum_size = Vector2(get_viewport_rect().size.x * (2.0/9.0), get_viewport_rect().size.y * (1.0/9.0))
	
	# upper button spacing
	up_selection_hbox.get_child(0).custom_minimum_size = Vector2(get_viewport_rect().size.x * (0.5/9.0), get_viewport_rect().size.y * (1.0/9.0))
	up_selection_hbox.get_child(1).custom_minimum_size = Vector2(get_viewport_rect().size.x * (0.5/9.0), get_viewport_rect().size.y * (1.0/9.0))
	up_selection_hbox.get_child(2).custom_minimum_size = Vector2(get_viewport_rect().size.x * (0.5/9.0), get_viewport_rect().size.y * (1.0/9.0))
	up_selection_hbox.get_child(3).custom_minimum_size = Vector2(get_viewport_rect().size.x * (2.5/9.0), get_viewport_rect().size.y * (1.0/9.0))
	
	# submenus prep
	for submenu in submenu_list:
		submenu.custom_open_size = Vector2(get_viewport_rect().size.x * (4.0/9.0), get_viewport_rect().size.y * (2.0/9.0))
		submenu.custom_close_size = Vector2(0.0, 0.0)
		submenu.open()
	toggle_collapsible()
	
	# left buttons init
	var i = 0
	for item in left_selection_vbox.get_children():
		item.get_child(0).connect("button_up", func(): toggle_collapsible_left(i))
		i = i + 1
	
	# upper buttons init
	var j = 0
	for item in [up_selection_hbox.get_child(0), up_selection_hbox.get_child(1), up_selection_hbox.get_child(2)]:
		item.get_child(0).connect("button_up", func(): toggle_collapsible_up(j))
		j = j + 1

func _process(_delta):
	if Input.is_action_just_pressed("tab"):
		menu_toggle()

func menu_toggle():
	collapse_menu.open_tween_toggle.call_deferred()
	hexagon_field.menu_active = !hexagon_field.menu_active

func toggle_collapsible_left(toggle_index):
	toggle_index_left = toggle_index
	toggle_collapsible()

func toggle_collapsible_up(toggle_index):
	toggle_index_up = toggle_index
	toggle_collapsible()

func toggle_collapsible():
	var next_collapsible = submenu_list[toggle_index_left * 3 + toggle_index_up]
	if next_collapsible == active_menu:
		return
	if active_menu != null:
		active_menu.open_tween_toggle.call_deferred()
	next_collapsible.open_tween_toggle.call_deferred()
	active_menu = next_collapsible
