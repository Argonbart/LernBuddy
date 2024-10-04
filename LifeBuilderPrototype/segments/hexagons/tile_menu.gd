extends PanelContainer

@onready var hexagon_controller = $"../../../HexagonController"
@onready var hexagons = $"../../../Hexagons"
@onready var container_list = $HBoxContainer
@onready var hexagon_camera = $"../../../Camera2D"

var hexagon_templates = []
var currently_hovered_button = null
var currently_selected_hexagon = null
var mouse_left_down = false

var menu_closed = true
var is_rotating = false

var viewport_offset = Vector2(2304/2, 1280/2)

func _ready():
	connect("mouse_entered", func(): _hovering_over_panel())
	connect("mouse_exited", func(): _stop_hovering_over_panel())
	for container in container_list.get_children():
		var button = container.get_child(0)
		button.connect("pressed", func(): _set_currently_hovered_hexagon(button))

func _process(_delta):
	if mouse_left_down:
		if currently_selected_hexagon:
			currently_selected_hexagon.position = (get_viewport().get_mouse_position() - viewport_offset + (hexagon_camera.position * hexagon_camera.zoom)) / hexagon_camera.zoom

func _hovering_over_panel():
	if menu_closed and !currently_selected_hexagon:
		hexagon_controller.menu_active = true
		var tween_grow_panel = create_tween()
		tween_grow_panel.tween_property(self, "custom_minimum_size", Vector2(0,get_viewport().size.y/4), 0.2)
		tween_grow_panel.tween_callback(func(): container_list.visible = true ; menu_closed = false)

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
	var tween_grow_panel = create_tween()
	tween_grow_panel.tween_property(self, "custom_minimum_size", Vector2(0,50), 0.2)
	tween_grow_panel.tween_callback(func(): menu_closed = true ; hexagon_controller.menu_active = false)

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
				if currently_selected_hexagon and hex_position_clicked in hexagon_controller.hexagon_field:
					if hexagon_controller.hexagon_field[hex_position_clicked] == null:
						hexagon_controller.move_hexagon_to(currently_selected_hexagon, hex_position_clicked)
					else:
						return
				mouse_left_down = false
				currently_selected_hexagon = null
