extends Node

signal stop_pressing_mouse_button()

@onready var tilemap = $"../TileMap"

const main_layer = 0
const main_atlas_id = 0

var mouse_left_down : bool = false
var current_holded_sprite : Sprite2D = null
var current_holded_tile_type : Vector2i = Vector2i(0,0)

var tilemap_tile_textures = {}

func _ready():
	connect("stop_pressing_mouse_button", _drop_hexagon)
	var tile_size = tilemap.get_tileset().get_tile_size();
	var tiles = tilemap.get_used_cells(0);
	var atlas_texture = AtlasTexture.new();
	atlas_texture.atlas = tilemap.get_tileset().get_source(0).texture;
	for tile_pos in tiles:
		var tile_atlas_coords = tilemap.get_cell_atlas_coords(0, tile_pos);
		var region = Rect2i(tile_atlas_coords * tile_size, tile_size);
		var texture = ImageTexture.create_from_image(atlas_texture.atlas.get_image().get_region(region));
		if tile_atlas_coords != Vector2i(0,0):
			tilemap_tile_textures[tile_pos] = texture

func _input(event):
	if event is InputEventMouseButton:
		if mouse_left_down and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if current_holded_sprite:
				current_holded_sprite.rotate(0.523599)
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			mouse_left_down = true
			var global_clicked = event.position
			print(global_clicked, " - ", tilemap.to_local(global_clicked), " - ", tilemap.local_to_map(tilemap.to_local(global_clicked)))
			var pos_clicked = tilemap.local_to_map(tilemap.to_local(global_clicked))
			if pos_clicked in tilemap_tile_textures.keys():
				current_holded_tile_type = tilemap.get_cell_atlas_coords(main_layer, pos_clicked)
				current_holded_sprite = Sprite2D.new()
				current_holded_sprite.texture = tilemap_tile_textures[pos_clicked]
				add_child(current_holded_sprite)
				remove_hexagon(pos_clicked)
		elif event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
			mouse_left_down = false
			stop_pressing_mouse_button.emit()

func _process(_delta):
	if mouse_left_down:
		if current_holded_sprite:
			current_holded_sprite.position = get_viewport().get_mouse_position()

func _drop_hexagon():
	if !current_holded_sprite:
		return
	var drop_position = Vector2i(round((get_viewport().get_mouse_position().x) / (462*0.2)), round((get_viewport().get_mouse_position().y) / (510*0.2)))
	place_hexagon(drop_position, current_holded_tile_type)
	current_holded_sprite.queue_free()
	current_holded_sprite = null

func remove_hexagon(position):
	tilemap.set_cell(main_layer, position, main_atlas_id, Vector2(0,0))
	tilemap_tile_textures.erase(position)

func place_hexagon(position, type):
	if current_holded_sprite:
		tilemap.set_cell(main_layer, position, main_atlas_id, type)
		tilemap_tile_textures[position] = current_holded_sprite.texture
