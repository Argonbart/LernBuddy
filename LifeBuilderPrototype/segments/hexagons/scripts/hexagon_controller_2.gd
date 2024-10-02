extends Node

signal stop_pressing_mouse_button()

@onready var hexagon_nodes = $"../Hexagons"
@onready var hexagon_tile_empty : PackedScene = load("res://segments/hexagons/hexagon_tiles/hexagon_empty.tscn")
@onready var hexagon_tile_straight_path : PackedScene = load("res://segments/hexagons/hexagon_tiles/hexagon_straight_path.tscn")
@onready var hexagon_tile_curved_path : PackedScene = load("res://segments/hexagons/hexagon_tiles/hexagon_curved_path.tscn")
@onready var hexagon_tile_crossing_path : PackedScene = load("res://segments/hexagons/hexagon_tiles/hexagon_crossing_path.tscn")


var q_basis = Vector2(sqrt(3), 0)
var r_basis = Vector2(sqrt(3), 3/2)
var size = 50
var grid_size = 8

var hexagon_field = {}

var mouse_left_down : bool = false
var current_hexagon : Node2D = null
var current_hexagon_reset_position : Vector2 = Vector2(0,0)
var current_hexagon_reset_rotation : float = 0.0

func _ready():
	generate_hex_grid()

func _process(_delta):
	if mouse_left_down:
		if current_hexagon:
			current_hexagon.position = get_viewport().get_mouse_position() - Vector2(1152/2, 640/2)

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
	var x = size * (sqrt(3) * hex_vector.x + sqrt(3)/2.0 * hex_vector.y)
	var y = size * (3.0/2.0 * hex_vector.y)
	return Vector2(x, y)

func pixel_to_hex(pixel_vector):
	var q = (sqrt(3)/3.0 * pixel_vector.x + -1.0/3.0 * pixel_vector.y) / size
	var r = (2.0/3.0 * pixel_vector.y) / size
	return axial_round(Vector2(q, r))

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
	
	return Vector3(q,r,s)

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
	new_hexagon_tile.position = hex_to_pixel(hex_vector)
	hexagon_nodes.add_child(new_hexagon_tile)
	return new_hexagon_tile

func move_hexagon_to(hexagon, hex_position):
	hexagon.position = hex_to_pixel(hex_position)
	hexagon_field[hex_position] = hexagon

func _input(event):
	if event is InputEventMouseButton:
		if mouse_left_down and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if current_hexagon:
				current_hexagon.rotate(0.523599)
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			mouse_left_down = true
			var field_clicked = event.position - Vector2(1152/2, 640/2)
			current_hexagon = hexagon_field[pixel_to_hex(field_clicked)]
			if current_hexagon:
				current_hexagon_reset_position = pixel_to_hex(field_clicked)
				current_hexagon_reset_rotation = current_hexagon.rotation
		elif event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
			mouse_left_down = false
			if current_hexagon:
				if hexagon_field[pixel_to_hex(event.position - Vector2(1152/2, 640/2))] == null:
					move_hexagon_to(current_hexagon, pixel_to_hex(event.position - Vector2(1152/2, 640/2)))
					hexagon_field[current_hexagon_reset_position] = null
				elif hexagon_field[pixel_to_hex(event.position - Vector2(1152/2, 640/2))] == current_hexagon:
					move_hexagon_to(current_hexagon, pixel_to_hex(event.position - Vector2(1152/2, 640/2)))
				else:
					move_hexagon_to(current_hexagon, current_hexagon_reset_position)
					current_hexagon.rotation = current_hexagon_reset_rotation
			current_hexagon = null
