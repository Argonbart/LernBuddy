extends Node

@onready var table_game = $".."
@onready var draw_widget = $DrawCardPanel

############################################ BONUS CARD VARIABLES #########################################################

var bonus_card_playable : bool = false
var active_bonus_card : String = ""
var confirmed_locked_field_position : int = -1
var richard_confirmed_locked_field_position : int = -1
var locked_by : String = ""
var locked_by2 : String = ""

# joker
var delete_field : ReferenceRect = null

# switch variables
var switch_selection_first_card_on : bool = false
var switch_selection_second_card_on : bool = false
var first_field_to_swap : ReferenceRect = null
var second_field_to_swap : ReferenceRect = null

# doublepoints
var double_field : ReferenceRect = null

# lock
var locking_field : ReferenceRect = null
var locking_field2 : ReferenceRect = null

var played_by : String = ""

############################################ JOKER #########################################################

func start_joker():
	table_game.highlighting_controller.highlight_fields_with_cards()
	table_game.joker_ongoing = true

func cancel_joker():
	table_game.highlighting_controller.highlight_no_fields()
	table_game.joker_ongoing = false
	if delete_field:
		table_game.highlighting_controller.highlight_bonus_card_off(delete_field)

func joker_field(field):
	if !field.get_node("Card").get_groups().has("FieldCard"):
		delete_field = null
		active_bonus_card = ""
		bonus_card_playable = false
		table_game.play_card_button.visible = false
		table_game.highlighting_controller.highlight_bonus_card_off(field)
	else:
		delete_field = field
		active_bonus_card = "joker"
		bonus_card_playable = true
		table_game.play_card_button.visible = true
		table_game.highlighting_controller.highlight_bonus_card_on(field)

func execute_joker():
	delete(delete_field)
	draw_widget.visible = true
	table_game.highlighting_controller.highlight_bonus_card_off(delete_field)

func delete(field):
	var field_card = field.find_child("Card")
	field_card.add_theme_stylebox_override("panel", load("res://segments/tavern/tavern_game/cards_colors_style_boxes/empty_card.tres"))
	field_card.get_theme_stylebox("panel").border_color = Color("#CCCCCC")
	var field_label = field_card.find_child("Text")
	field_label.text = ""
	field_label.visible = true
	var field_icon = field_card.find_child("Icon")
	field_icon.set_texture(null)
	field_icon.visible = true
	field_card.remove_from_group("FieldCard")
	table_game.field_to_preview_cards[field_card].queue_free()
	table_game.field_to_preview_cards.erase(field_card)

func initiate_draw_widget():
	for color in ["red", "yellow", "green", "blue"]:
		var option_card = create_joker_card(color)
		var option_button = Button.new()
		option_button.custom_minimum_size = Vector2(100, 100)
		option_button.flat = true
		option_button.connect("pressed", func(): _color_selected(color))
		option_card.add_child(option_button)
		draw_widget.find_child("DrawOptions").add_child(option_card)

func _color_selected(color):
	table_game.create_hand_card(color, table_game.card_icons[color])
	draw_widget.visible = false
	table_game.joker_ongoing = false
	bonus_card_played_successfully("joker")

############################################ SWITCH #########################################################

func start_switch():
	table_game.highlighting_controller.highlight_fields_with_cards()
	switch_selection_first_card_on = true
	table_game.switch_ongoing = true

func cancel_switch():
	table_game.highlighting_controller.highlight_no_fields()
	if first_field_to_swap:
		table_game.highlighting_controller.highlight_bonus_card_off(first_field_to_swap)
	if second_field_to_swap:
		table_game.highlighting_controller.highlight_bonus_card_off(second_field_to_swap)
	switch_selection_first_card_on = false
	switch_selection_second_card_on = false
	table_game.switch_ongoing = false

func switch_field(field):
	
	if switch_selection_first_card_on:
		switch_first_field(field)
		return
		
	if switch_selection_second_card_on:
		switch_second_field(field)
		return

func switch_first_field(field):
	first_field_to_swap = field
	if !first_field_to_swap.get_node("Card").get_groups().has("FieldCard") or field == locking_field or field == locking_field2:
		return
	table_game.highlighting_controller.highlight_all_fields()				#### EXPECT LOCKED CARDS, those should not light up - TODO
	table_game.highlighting_controller.highlight_bonus_card_on(field)
	switch_selection_first_card_on = false
	switch_selection_second_card_on = true

func switch_second_field(field):
	second_field_to_swap = field
	if (second_field_to_swap.get_node("Card").get_groups().has("FieldCard") and field == locking_field) or (second_field_to_swap.get_node("Card").get_groups().has("FieldCard") and field == locking_field2):
		return
	table_game.highlighting_controller.highlight_bonus_card_on(field)
	active_bonus_card = "switch"
	bonus_card_playable = true
	table_game.play_card_button.visible = true
	switch_selection_second_card_on = false

func execute_switch():
	switch_fields(first_field_to_swap, second_field_to_swap)
	bonus_card_played_successfully("switch")
	table_game.point_system_controller.calculate_points(table_game.gameboard_fields.find(first_field_to_swap), played_by)
	table_game.point_system_controller.calculate_points(table_game.gameboard_fields.find(second_field_to_swap), played_by)
	table_game.highlighting_controller.highlight_bonus_card_off(first_field_to_swap)
	table_game.highlighting_controller.highlight_bonus_card_off(second_field_to_swap)

# Swaps cards inside the fields manually
func switch_fields(field1, field2):
	var field_to_preview_cards = table_game.field_to_preview_cards
	var card1 = field1.find_child("Card")
	var card2 = field2.find_child("Card")
	if card1 in field_to_preview_cards and card2 in field_to_preview_cards:
		var preview_temp = field_to_preview_cards[card1]
		field_to_preview_cards[card1] = field_to_preview_cards[card2]
		field_to_preview_cards[card2] = preview_temp
	elif card1 in field_to_preview_cards:
		field_to_preview_cards[card2] = field_to_preview_cards[card1]
	elif card2 in field_to_preview_cards:
		field_to_preview_cards[card1] = field_to_preview_cards[card2]
	var index1 = card1.get_index()
	var index2 = card2.get_index()
	field1.remove_child(card1)
	field2.remove_child(card2)
	field1.add_child(card2)
	field2.add_child(card1)
	field1.move_child(card2, index2)
	field2.move_child(card1, index1)
	card1.owner = field2
	card2.owner = field1
	for child in card1.get_children():
		child.owner = card1
	for child in card2.get_children():
		child.owner = card2

############################################ DOUBLE POINTS #########################################################

func start_doublepoints():
	table_game.highlighting_controller.highlight_all_fields()
	table_game.doublepoints_ongoing = true

func cancel_doublepoints():
	table_game.highlighting_controller.highlight_no_fields()
	table_game.doublepoints_ongoing = false
	if double_field:
		table_game.highlighting_controller.highlight_bonus_card_off(double_field)

func doublepoints_field(field):
	double_field = field
	active_bonus_card = "doublepoints"
	bonus_card_playable = true
	table_game.play_card_button.visible = true
	table_game.highlighting_controller.highlight_bonus_card_on(field)

func execute_doublepoints():
	create_doublepoints_field(double_field)
	bonus_card_played_successfully("doublepoints")
	table_game.point_system_controller.doublepoints_field_position = table_game.gameboard_fields.find(double_field)
	table_game.highlighting_controller.highlight_bonus_card_off(double_field)

func create_doublepoints_field(field):
	var doublepoints_node = Control.new()
	doublepoints_node.name = "DoublePoints"
	doublepoints_node.custom_minimum_size = Vector2(35, 35)
	doublepoints_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var border_panel = Panel.new()
	border_panel.name = "Border"
	border_panel.custom_minimum_size = Vector2(37, 37)
	border_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	border_panel.add_theme_stylebox_override("panel", load("res://segments/tavern/tavern_game/gameboard_visual_styles/bonus_card_border.tres"))
	border_panel.anchor_left = 0.5
	border_panel.anchor_top = 0.5
	border_panel.anchor_right = 0.5
	border_panel.anchor_bottom = 0.5
	border_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	border_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	
	var x2_label = Label.new()
	x2_label.name = "X2"
	x2_label.custom_minimum_size = Vector2(300, 300)
	x2_label.scale = Vector2(0.05, 0.05)
	x2_label.offset_left = 21
	x2_label.offset_top = 21
	x2_label.add_theme_font_size_override("font_size", 200)
	x2_label.add_theme_color_override("font_color", Color("#FFFFFF"))
	x2_label.text = "X2"
	
	doublepoints_node.add_child(border_panel)
	doublepoints_node.add_child(x2_label)
	field.add_child(doublepoints_node)
	field.move_child(doublepoints_node, 2)

############################################ LOCK #########################################################

func start_lock():
	table_game.highlighting_controller.highlight_all_fields()
	table_game.lock_ongoing = true

func cancel_lock():
	table_game.highlighting_controller.highlight_no_fields()
	table_game.lock_ongoing = false
	if locking_field:
		table_game.highlighting_controller.highlight_bonus_card_off(locking_field)

func lock_field(field):
	locking_field = field
	active_bonus_card = "lock"
	bonus_card_playable = true
	table_game.play_card_button.visible = true
	table_game.highlighting_controller.highlight_bonus_card_on(field)

func execute_lock():
	create_locked_field(locking_field)
	if !locking_field.get_node("Card").get_groups().has("FieldCard"):
		confirmed_locked_field_position = table_game.gameboard_fields.find(locking_field)
		locked_by = played_by
	bonus_card_played_successfully("lock")
	table_game.highlighting_controller.highlight_bonus_card_off(locking_field)

func richard_execute_lock():
	create_locked_field(locking_field2)
	if !locking_field2.get_node("Card").get_groups().has("FieldCard"):
		richard_confirmed_locked_field_position = table_game.gameboard_fields.find(locking_field2)
		locked_by2 = "Richard"

func create_locked_field(field):
	var locked_node = Control.new()
	locked_node.name = "Locked"
	locked_node.custom_minimum_size = Vector2(35, 35)
	locked_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var border_panel = Panel.new()
	border_panel.name = "Border"
	border_panel.custom_minimum_size = Vector2(37, 37)
	border_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	border_panel.add_theme_stylebox_override("panel", load("res://segments/tavern/tavern_game/gameboard_visual_styles/bonus_card_border.tres"))
	border_panel.anchor_left = 0.5
	border_panel.anchor_top = 0.5
	border_panel.anchor_right = 0.5
	border_panel.anchor_bottom = 0.5
	border_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	border_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	
	var locked_icon = TextureRect.new()
	locked_icon.name = "Icon"
	locked_icon.custom_minimum_size = Vector2(15, 15)
	locked_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	locked_icon.texture = load(table_game.bonus_card_icons["lock"])
	locked_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	locked_icon.size = Vector2(15,15)
	locked_icon.offset_left = 2
	locked_icon.offset_top = 17
	
	locked_node.add_child(border_panel)
	locked_node.add_child(locked_icon)
	field.add_child(locked_node)
	field.move_child(locked_node, 2)

###########################################################################################################

func confirm_bonus_card_play():
	return bonus_card_playable

func execute_bonus_card():
	if active_bonus_card == "joker":
		execute_joker()
	elif active_bonus_card == "switch":
		execute_switch()
	elif active_bonus_card == "doublepoints":
		execute_doublepoints()
	elif active_bonus_card == "lock":
		execute_lock()

func bonus_card_played_successfully(type):
	table_game.highlighting_controller.highlight_no_fields()
	table_game.bonus_cards[type].queue_free()
	table_game.bonus_cards.erase(type)
	table_game.player_deck.get_child(len(table_game.player_deck.get_children())-2).queue_free()
	table_game.player_played_bonus_card = true
	table_game.switch_ongoing = false
	table_game.joker_ongoing = false
	table_game.doublepoints_ongoing = false
	table_game.lock_ongoing = false

func currently_playing(player):
	played_by = player

func create_joker_card(color):
	
	# Card Panel
	var new_small_card = Panel.new()
	new_small_card.custom_minimum_size = Vector2(100, 100)
	new_small_card.add_theme_stylebox_override("panel", table_game.style_boxes[color])
	new_small_card.size_flags_horizontal = Control.SIZE_SHRINK_CENTER | Control.SIZE_EXPAND
	
	# Card Icon
	var new_icon = TextureRect.new()
	new_icon.texture = load(table_game.card_icons[color])
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

	return new_small_card
