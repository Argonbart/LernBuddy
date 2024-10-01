extends Node2D

var textures = ["res://ressources/tilemaps/hex_t3_1.png",
				"res://ressources/tilemaps/hex_t3_2.png",
				"res://ressources/tilemaps/hex_t3_3.png",
				"res://ressources/tilemaps/hex_t3_4.png",
				"res://ressources/tilemaps/hex_t3_5.png",
				"res://ressources/tilemaps/hex_t3_6.png"]
var current_texture = 0

var rotation_counter = 0
var rotation_save = 0
var started = false

func _ready():
	get_child(0).texture = load(textures[0])

func _process(_delta):
	if Input.is_key_pressed(KEY_F7):
		started = true
	if started:
		if rotation_counter == 61:
			rotation_counter = 62
			await get_tree().create_timer(1.0).timeout
			rotation_save = rotation_save + 60
			if rotation_save == 360:
				rotation_save = 0
			rotation_counter = 0
			current_texture = current_texture + 1
			if current_texture > 5:
				current_texture = 0
			#get_child(0).texture = load(textures[current_texture])
			print(rotation_save)
		elif rotation_counter > 61:
			pass
		else:
			rotation_degrees = rotation_save + rotation_counter
			rotation_counter = rotation_counter + 1
