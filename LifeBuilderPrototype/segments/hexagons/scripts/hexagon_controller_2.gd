extends Node

signal stop_pressing_mouse_button()

@onready var hexagon_field = $"../Hexagons"
@onready var hexagon_tile_empty : PackedScene = load("res://segments/hexagons/hexagon_tiles/hexagon_empty.tscn")
@onready var hexagon_tile_straight_path : PackedScene = load("res://segments/hexagons/hexagon_tiles/hexagon_straight_path.tscn")

var q_basis = Vector2(sqrt(3), 0)
var r_basis = Vector2(sqrt(3), 3/2)
var size = 50
var grid_size = 3

var mouse_left_down : bool = false
var current_hexagon : Node2D = null

func _ready():
	generate_hex_grid()
	current_hexagon = new_hexagon(hexagon_tile_straight_path, Vector2(0,0))
	print(pixel_to_hex(current_hexagon.position))

func _process(_delta):
	pass

func generate_hex_grid():
	for q in range(-1 * grid_size, 0):
		for r in range(-1 * grid_size - q, grid_size + 1):
			new_hexagon(hexagon_tile_empty, Vector2(q, r))
	for q in range(0, grid_size + 1):
		for r in range(-1 * grid_size, grid_size + 1 - q):
			new_hexagon(hexagon_tile_empty, Vector2(q, r))

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
	new_hexagon_tile.global_position = hex_to_pixel(hex_vector)
	hexagon_field.add_child(new_hexagon_tile)
	return new_hexagon_tile

func _input(event):
	if event is InputEventMouseButton:
		if mouse_left_down and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			pass
			#if current_holded_sprite:
				#current_holded_sprite.rotate(0.523599)
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			mouse_left_down = true
			var field_clicked = event.global_position - Vector2(get_viewport().size/2)
			print(field_clicked)
			print(pixel_to_hex(field_clicked))
			
			
			#print(global_clicked, " - ", tilemap.to_local(global_clicked), " - ", tilemap.local_to_map(tilemap.to_local(global_clicked)))
			#var pos_clicked = tilemap.local_to_map(tilemap.to_local(global_clicked))
			#if pos_clicked in tilemap_tile_textures.keys():
				#current_holded_tile_type = tilemap.get_cell_atlas_coords(main_layer, pos_clicked)
				#current_holded_sprite = Sprite2D.new()
				#current_holded_sprite.texture = tilemap_tile_textures[pos_clicked]
				#add_child(current_holded_sprite)
				#remove_hexagon(pos_clicked)
		elif event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
			mouse_left_down = false
			stop_pressing_mouse_button.emit()
