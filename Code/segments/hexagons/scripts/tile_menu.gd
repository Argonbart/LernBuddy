extends PanelContainer

#################################### VARIABLES & IMPORTS ####################################

@onready var hexagon_controller = $"../../../HexagonController"
@onready var hexagons = $"../../../Hexagons"
@onready var container_list = $HBoxContainer
@onready var hexagon_camera = $"../../../Camera2D"
@onready var delete_field = $DeleteField

var menu_hexagon_container_template = load("res://segments/hexagons/scenes/templates/menu_hexagon_container_template.tscn")
var menu_hexagon_list = []

var hexagon_templates = []
var currently_hovered_button = null
var currently_selected_hexagon = null
var mouse_left_down = false

var menu_closed = true
var is_rotating = false

var viewport_offset = Vector2(2304/2, 1280/2)

var mouse_over_delete = false

#################################### INITIALIZE ####################################

func _ready():
	generate_menu_hexagons()
	connect("mouse_entered", func(): _hovering_over_panel())
	connect("mouse_exited", func(): _stop_hovering_over_panel())
	for container in container_list.get_children():
		var button = container.get_child(0)
		button.connect("button_down", func(): _set_currently_hovered_hexagon(button))
	delete_field.connect("mouse_entered", func(): mouse_over_delete = true)
	delete_field.connect("mouse_exited", func(): mouse_over_delete = false)

func generate_menu_hexagons():
	for hexagon_tile_texture in hexagon_controller.hexagon_tile_textures_list:
		var new_menu_hexagon_type = menu_hexagon_container_template.instantiate()
		new_menu_hexagon_type.get_child(0).texture_normal = load(hexagon_tile_texture)
		new_menu_hexagon_type.get_child(1).get_child(0).texture = load(hexagon_tile_texture)
		menu_hexagon_list.append(new_menu_hexagon_type)
	for menu_hexagon in menu_hexagon_list:
		container_list.add_child(menu_hexagon)

#################################### CONNECT FUNCTIONS ####################################

func _hovering_over_panel():
	if menu_closed and !currently_selected_hexagon:
		hexagon_controller.menu_active = true
		hexagon_controller.menu_hexagon_active = true
		var tween_grow_panel = create_tween()
		tween_grow_panel.tween_property(self, "custom_minimum_size", Vector2(0,get_viewport().size.y/4), 0.2)
		tween_grow_panel.tween_callback(func(): container_list.visible = true ; delete_field.visible = true ; menu_closed = false)

func _stop_hovering_over_panel():
	close_menu()

func _set_currently_hovered_hexagon(button):
	var new_hexagon = button.get_parent().get_child(1).duplicate()
	hexagons.add_child(new_hexagon)
	mouse_left_down = true
	currently_selected_hexagon = new_hexagon
	currently_selected_hexagon.visible = true
	close_menu()

func close_menu():
	container_list.visible = false
	if currently_selected_hexagon == null:
		delete_field.visible = false
	var tween_grow_panel = create_tween()
	tween_grow_panel.tween_property(self, "custom_minimum_size", Vector2(0,50), 0.2)
	tween_grow_panel.tween_callback(func(): menu_closed = true ; hexagon_controller.menu_active = false)

#################################### INPUTS ####################################

func _process(_delta):
	if mouse_left_down:
		if currently_selected_hexagon:
			currently_selected_hexagon.position = (get_viewport().get_mouse_position() - viewport_offset + (hexagon_camera.position * hexagon_camera.zoom)) / hexagon_camera.zoom

func _input(event):
	if mouse_left_down:
		if event is InputEventKey:
			if event.keycode == KEY_E and !is_rotating:
				if currently_selected_hexagon:
					is_rotating = true
					currently_selected_hexagon.rotate(1.047198)
			if event.keycode == KEY_Q and !is_rotating:
				if currently_selected_hexagon:
					is_rotating = true
					currently_selected_hexagon.rotate(-1.047198)
			if event.keycode == KEY_E and event.is_released():
				is_rotating = false
			if event.keycode == KEY_Q and event.is_released():
				is_rotating = false
		if event is InputEventMouseButton:
			var pixel_position_clicked = event.position - viewport_offset + (hexagon_camera.position * hexagon_camera.zoom)
			var hex_position_clicked = hexagon_controller.pixel_to_hex(pixel_position_clicked)
			if event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
				if mouse_over_delete:
					currently_selected_hexagon.queue_free()
					delete_field.visible = false
				elif currently_selected_hexagon and hex_position_clicked in hexagon_controller.hexagon_field:
					if hexagon_controller.hexagon_field[hex_position_clicked] == null:
						hexagon_controller.move_hexagon_to(currently_selected_hexagon, hex_position_clicked)
						delete_field.visible = false
					else:
						return
				mouse_left_down = false
				currently_selected_hexagon = null
				hexagon_controller.menu_hexagon_active = false
