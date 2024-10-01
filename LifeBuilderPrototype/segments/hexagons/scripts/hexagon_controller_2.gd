extends Node

signal stop_pressing_mouse_button()

@onready var hexagon_field = $"../Hexagons"
@onready var hexagon_tile_empty : PackedScene = load("res://segments/hexagons/hexagon_tiles/hexagon_empty.tscn")
@onready var hexagon_tile_straight_path : PackedScene = load("res://segments/hexagons/hexagon_tiles/hexagon_straight_path.tscn")

var q_basis = Vector2(sqrt(3), 0)
var r_basis = Vector2(sqrt(3), 3/2)
var size = 50
var grid_size = 8

func _ready():
	generate_hex_grid()
	new_hexagon(hexagon_tile_straight_path, 0, 0)

func _process(_delta):
	pass

func generate_hex_grid():
	for q in range(-1 * grid_size, 0):
		for r in range(-1 * grid_size - q, grid_size + 1):
			new_hexagon(hexagon_tile_empty, q, r)
	for q in range(0, grid_size + 1):
		for r in range(-1 * grid_size, grid_size + 1 - q):
			new_hexagon(hexagon_tile_empty, q, r)

func hex_to_pixel(hex_q, hex_r):
	var x = size * (sqrt(3) * hex_q + sqrt(3)/2.0 * hex_r)
	var y = size * (3.0/2.0 * hex_r)
	return Vector2(x, y)

func new_hexagon(tile, hex_q, hex_r):
	var new_hexagon_tile = tile.instantiate()
	new_hexagon_tile.position = hex_to_pixel(hex_q, hex_r)
	hexagon_field.add_child(new_hexagon_tile)
