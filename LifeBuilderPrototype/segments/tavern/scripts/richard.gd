extends CharacterBody2D

@onready var table_game = $"../TableGame"

func _ready():
	table_game.connect("player_played_card", func(): player_played_card())

func _process(_delta):
	self.get_child(0).play("idle")

func player_played_card():
	
	# Logic to implement Richard moves
	var possible_fields_to_play = []
	for field in table_game.gameboard_fields:
		if field.get_child(1).get_class() != "Panel":
			possible_fields_to_play.append(field)
	var field_pos_to_play = table_game.gameboard_fields.find(possible_fields_to_play[randi_range(0, len(possible_fields_to_play)-1)])
	######################################
	
	richard_play_card(field_pos_to_play, "red", "Richard Card Text")

func richard_play_card(position, color, text):
	create_field_card(position, color, table_game.card_icons[color], text)
	table_game.gameboard_fields[position].move_child(table_game.gameboard_fields[position].get_child(2), 1)

###############################################################
###############################################################
###############################################################
func create_field_card(field_position, color, icon_path, text):
	var new_field_card = create_small_card(color, "Text", icon_path, text)
	var new_preview_card = create_preview_card(color, text)
	table_game.gameboard_fields[field_position].add_child(new_field_card)
	table_game.field_to_preview_cards[new_field_card] = new_preview_card
	return new_field_card

func create_preview_card(color, text):
	var new_preview_card = create_big_card(color, "Preview", text)
	table_game.field_cards_preview.add_child(new_preview_card)
	return new_preview_card

# color = "red" | "yellow" | "green" | "blue" | "grey" | "aquamarine"
# type = "Text" | "Icon"
# icon_path = Path zu Icon-Texture
# text = String an Text für das Label
func create_small_card(color, type, icon_path, text):
	
	# Card Panel
	var new_small_card = Panel.new()
	new_small_card.custom_minimum_size = Vector2(35, 35)
	new_small_card.add_theme_stylebox_override("panel", table_game.style_boxes[color])
	new_small_card.size_flags_horizontal = Control.SIZE_SHRINK_CENTER | Control.SIZE_EXPAND
	
	# Card Label
	var new_text_label = Label.new()
	new_text_label.custom_minimum_size = Vector2(600, 600)
	new_text_label.scale = Vector2(0.05, 0.05)
	new_text_label.offset_left = 2
	new_text_label.offset_top = 2
	new_text_label.offset_right = 2
	new_text_label.offset_bottom = 2
	new_text_label.text = text
	new_text_label.add_theme_color_override("background_color", table_game.style_boxes[color].bg_color)
	new_text_label.add_theme_color_override("font_color", Color.BLACK)
	new_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	new_text_label.add_theme_font_size_override("font_size", 50)
	new_text_label.clip_text = true
	new_small_card.add_child(new_text_label)
	
	# Card Icon
	var new_icon = TextureRect.new()
	new_icon.texture = load(icon_path)
	new_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	new_icon.set_anchor(SIDE_TOP, 0.0)
	new_icon.set_anchor(SIDE_BOTTOM, 1.0)
	new_icon.set_anchor(SIDE_LEFT, 0.0)
	new_icon.set_anchor(SIDE_RIGHT, 1.0)
	new_icon.offset_top = 5.0
	new_icon.offset_bottom = -5.0
	new_icon.offset_left = 5.0
	new_icon.offset_right = -5.0
	new_small_card.add_child(new_icon)
	
	# Only show Label or Icon, not both
	if type == "Text":
		new_icon.visible = false
	elif type == "Icon":
		new_text_label.visible = false
	else:
		printerr("Invalid Card Type. Only Label or Icon accepted.")
	
	return new_small_card

# color = "red" | "yellow" | "green" | "blue" | "grey" | "aquamarine"
# type = "Edit" | "Preview"
# text = String an Text
func create_big_card(color, type, text):
	
	# Card Panel
	var new_big_card = Panel.new()
	new_big_card.custom_minimum_size = Vector2(100, 100)
	new_big_card.add_theme_stylebox_override("panel", table_game.style_boxes[color])
	
	# Card TextEdit
	var new_text_edit = TextEdit.new()
	new_text_edit.custom_minimum_size = Vector2(1900, 1900)
	new_text_edit.scale = Vector2(0.05, 0.05)
	new_text_edit.offset_left = 2
	new_text_edit.offset_top = 2
	new_text_edit.offset_right = 2
	new_text_edit.offset_bottom = 2
	new_text_edit.placeholder_text = text
	new_text_edit.add_theme_color_override("background_color", table_game.style_boxes[color].bg_color)
	new_text_edit.add_theme_color_override("font_color", Color.BLACK)
	new_text_edit.add_theme_color_override("font_placeholder_color", Color.BLACK)
	new_text_edit.add_theme_font_size_override("font_size", 100)
	new_text_edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	new_big_card.add_child(new_text_edit)
	new_big_card.visible = false
	
	# Only allow to edit on Edit Cards
	if type == "Edit": # Edit Card
		new_text_edit.editable = true
	elif type == "Preview": # Preview Card
		new_text_edit.editable = false
	else:
		printerr("Invalid Card Type. Only Edit or Preview accepted.")
	
	return new_big_card
