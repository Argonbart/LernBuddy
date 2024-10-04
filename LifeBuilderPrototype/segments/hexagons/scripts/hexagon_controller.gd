extends Node

signal stop_pressing_mouse_button()

@onready var hexagon_nodes = $"../Hexagons"
@onready var hexagon_camera = $"../Camera2D"
@onready var hexagon_tile_empty : PackedScene = load("res://segments/hexagons/hexagon_tiles/hexagon_empty.tscn")
@onready var hexagon_tile_straight_path : PackedScene = load("res://segments/hexagons/hexagon_tiles/hexagon_straight_path.tscn")
@onready var hexagon_tile_curved_path : PackedScene = load("res://segments/hexagons/hexagon_tiles/hexagon_curved_path.tscn")
@onready var hexagon_tile_crossing_path : PackedScene = load("res://segments/hexagons/hexagon_tiles/hexagon_crossing_path.tscn")

var hexagon_tile_list = ["res://segments/hexagons/hexagon_tiles/hexagon_straight_path.tscn",
						 "res://segments/hexagons/hexagon_tiles/hexagon_curved_path.tscn",
						 "res://segments/hexagons/hexagon_tiles/hexagon_crossing_path.tscn"]

var q_basis = Vector2(3.0/2.0, sqrt(3)/2.0)
var r_basis = Vector2(0, sqrt(3))
var size = 165.5
var grid_size = 10

var hexagon_field = {}

var viewport_offset = Vector2(2304/2, 1280/2)
var mouse_left_down : bool = false
var is_rotating : bool = false
var current_hexagon = null
var current_hexagon_reset_position : Vector2 = Vector2(0,0)
var current_hexagon_reset_rotation : float = 0.0

var menu_active = false

func _ready():
	generate_hex_grid()

func _process(_delta):
	if mouse_left_down:
		if current_hexagon:
			current_hexagon.position = (get_viewport().get_mouse_position() - viewport_offset + (hexagon_camera.position * hexagon_camera.zoom)) / hexagon_camera.zoom

func generate_hex_grid():
	for q in range(-1 * grid_size, 0):
		for r in range(-1 * grid_size - q, grid_size + 1):
			new_hexagon(hexagon_tile_empty, Vector2(q, r))
			hexagon_field[Vector2(q,r)] = null
	for q in range(0, grid_size + 1):
		for r in range(-1 * grid_size, grid_size + 1 - q):
			new_hexagon(hexagon_tile_empty, Vector2(q, r))
			hexagon_field[Vector2(q,r)] = null
	for key in hexagon_field.keys():
		var random_number = randi_range(1,10)
		if random_number > 3:
			pass
		elif random_number == 1:
			hexagon_field[key] = new_hexagon(hexagon_tile_straight_path, key)
		elif random_number == 2:
			hexagon_field[key] = new_hexagon(hexagon_tile_curved_path, key)
		elif random_number == 3:
			hexagon_field[key] = new_hexagon(hexagon_tile_crossing_path, key)

func hex_to_pixel(hex_vector):
	var x = size * (3.0/2.0 * hex_vector.x)
	var y = size * (sqrt(3)/2.0 * hex_vector.x + sqrt(3) * hex_vector.y)
	var return_vector = Vector2(x, y)
	return return_vector

func pixel_to_hex(pixel_vector):
	var q = (2.0/3.0 * pixel_vector.x) / size
	var r = (-1.0/3.0 * pixel_vector.x + sqrt(3)/3.0 * pixel_vector.y) / size
	var return_vector = Vector2(q, r) / hexagon_camera.zoom
	return axial_round(return_vector)

func axial_round(hex_vector):
	return cube_to_axial(cube_round(axial_to_cube(hex_vector)))

func cube_round(frac_vector):
	
	var q = round(frac_vector.x)
	var r = round(frac_vector.y)
	var s = round(frac_vector.z)
	
	var q_diff = abs(q - frac_vector.x)
	var r_diff = abs(q - frac_vector.y)
	var s_diff = abs(q - frac_vector.z)
	
	if q_diff > r_diff and q_diff > s_diff:
		q = -r-s
	elif r_diff > s_diff:
		r = -q-s
	else:
		s = -q-r
	
	var return_vector = Vector3(q,r,s)
	
	var min_cord = (-1) * grid_size
	var max_cord = grid_size
	if q < min_cord:
		if r > max_cord:
			return_vector = Vector3(min_cord, max_cord, 0)
		else:
			return_vector = Vector3(min_cord, 0, max_cord)
	elif q > max_cord:
		if r < min_cord:
			return_vector = Vector3(max_cord, min_cord, 0)
		else:
			return_vector = Vector3(max_cord, 0, min_cord)
	else:
		if r < min_cord or s > max_cord:
			return_vector = Vector3(0, min_cord, max_cord)
		if r > max_cord or s < min_cord:
			return_vector = Vector3(0, max_cord, min_cord)
	
	return return_vector

func cube_to_axial(cube_vector):
	var q = cube_vector.x
	var r = cube_vector.y
	return Vector2(q,r)

func axial_to_cube(hex_vector):
	var q = hex_vector.x
	var r = hex_vector.y
	var s = -q-r
	return Vector3(q,r,s)

func new_hexagon(tile, hex_vector):
	var new_hexagon_tile = tile.instantiate()
	new_hexagon_tile.global_position = hex_to_pixel(hex_vector)
	hexagon_nodes.add_child(new_hexagon_tile)
	return new_hexagon_tile

func move_hexagon_to(hexagon, hex_position):
	hexagon.global_position = hex_to_pixel(hex_position)
	hexagon_field[hex_position] = hexagon

func _input(event):
	if !menu_active:
		if event is InputEventKey:
			if event.keycode == KEY_E and !is_rotating:
				if current_hexagon:
					is_rotating = true
					current_hexagon.rotate(1.047198)
			if event.keycode == KEY_Q and !is_rotating:
				if current_hexagon:
					is_rotating = true
					current_hexagon.rotate(-1.047198)
			if event.keycode == KEY_E and event.is_released():
				is_rotating = false
			if event.keycode == KEY_Q and event.is_released():
				is_rotating = false
		if event is InputEventMouseButton:
			var pixel_position_clicked = event.position - viewport_offset + (hexagon_camera.position * hexagon_camera.zoom)
			var hex_position_clicked = pixel_to_hex(pixel_position_clicked)
			if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
				mouse_left_down = true
				if hex_position_clicked in hexagon_field.keys():
					current_hexagon = hexagon_field[hex_position_clicked]
				if current_hexagon:
					current_hexagon_reset_position = hex_position_clicked
					current_hexagon_reset_rotation = current_hexagon.rotation
			elif event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
				mouse_left_down = false
				if current_hexagon and hex_position_clicked in hexagon_field:
					if hexagon_field[hex_position_clicked] == null:
						move_hexagon_to(current_hexagon, hex_position_clicked)
						hexagon_field[current_hexagon_reset_position] = null
					elif hexagon_field[hex_position_clicked] == current_hexagon:
						move_hexagon_to(current_hexagon, hex_position_clicked)
					else:
						move_hexagon_to(current_hexagon, current_hexagon_reset_position)
						current_hexagon.rotation = current_hexagon_reset_rotation
				current_hexagon = null
