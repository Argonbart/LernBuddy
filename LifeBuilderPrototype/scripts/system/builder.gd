extends TileMap

@export var world : Node2D

func _process(_delta):
	if !world.dialogue_active:
		if Input.is_action_just_pressed("build"):
			var pos = local_to_map(to_local(get_global_mouse_position()))
			build_house(pos)

func build_house(pos):
	build_fundament(pos)
	build_roof(pos)
	build_extras(pos)

func build_fundament(pos):
	for atlas_pos_x in range(62,68):
		for atlas_pos_y in range(21,25):
			set_cell(1, Vector2i(pos.x + atlas_pos_x-62, pos.y + atlas_pos_y-21), 1, Vector2i(atlas_pos_x, atlas_pos_y))

func build_roof(pos):
	for atlas_pos_x in range(1,7):
		for atlas_pos_y in range(12,17):
			set_cell(2, Vector2i(pos.x + atlas_pos_x-1, pos.y + atlas_pos_y-15), 1, Vector2i(atlas_pos_x, atlas_pos_y))

func build_extras(pos):
	for atlas_pos_x in range(5,7):
		for atlas_pos_y in range(56,58):
			set_cell(3, Vector2i(pos.x + atlas_pos_x-3, pos.y + atlas_pos_y-54), 1, Vector2i(atlas_pos_x, atlas_pos_y))
