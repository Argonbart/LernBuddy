extends Node

signal create_locked_field_return()
signal create_doublepoints_field_return()
signal switch_fields_return1()
signal switch_fields_return2()
signal delete_return()

@onready var table_game = $".."
@onready var draw_widget = $DrawCardPanel
@onready var block_panel = $"../RichardsTurnPanel"

var highlighter

############################################ BONUS CARD VARIABLES #########################################################

var bonus_card_playable : bool = false
var active_bonus_card : String = ""
var confirmed_locked_field_position : int = -1
var richard_confirmed_locked_field_position : int = -1
var locked_by : String = ""
var locked_by2 : String = ""

# joker
var joker_field_to_delete : ReferenceRect = null

# switch variables
var first_switch_card_is_selected : bool = false
var second_switch_card_is_selected : bool = false
var first_switch_field : ReferenceRect = null
var second_switch_field : ReferenceRect = null

# doublepoints
var double_field : ReferenceRect = null

# lock
var field_locked_by_player : ReferenceRect = null
var field_locked_by_richard : ReferenceRect = null

var played_by : String = ""
var hand
var hand_return

############################################ JOKER #########################################################

func start_joker():
	table_game.joker_ongoing = true
	highlighter.joker_clicked()

func cancel_joker():
	table_game.joker_ongoing = false
	highlighter.joker_canceled()

func joker_field(field):
	if field.get_node("Card").get_groups().has("FieldCard"):
		joker_field_to_delete = field
		active_bonus_card = "joker"
		bonus_card_playable = true
		table_game.play_card_button.visible = true
		highlighter.joker_field_selected()

func execute_joker():
	await delete(joker_field_to_delete)
	highlighter.joker_execute()

func delete(field):
	block_panel.visible = true
	var first_tween = create_tween()
	first_tween.tween_property(hand, "position", Vector2(field.position.x, field.position.y), 0.8 * table_game.turn_time)
	first_tween.connect("finished", func(): _delete_tween_finished(field))
	await delete_return

func _delete_tween_finished(field):
	await get_tree().create_timer(0.2 * table_game.turn_time).timeout
	hand.position = hand_return
	delete2(field)
	block_panel.visible = false
	delete_return.emit()

func delete2(field):
	var field_card = field.find_child("Card")
	field_card.add_theme_stylebox_override("panel", load("res://segments/tavern_game/cards_colors_style_boxes/empty_card.tres"))
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
	if played_by == "Player":
		draw_widget.visible = true

func initiate_draw_widget():
	for color in ["red", "yellow", "green", "blue"]:
		var option_card = create_joker_card(color)
		var option_button = Button.new()
		option_button.custom_minimum_size = Vector2(100, 100)
		option_button.flat = true
		option_button.connect("pressed", func(): _color_selected(color))
		option_card.add_child(option_button)
		draw_widget.find_child("DrawOptions").add_child(option_card)
	highlighter = table_game.highlighting_controller

func _color_selected(color):
	table_game.create_hand_card(color, table_game.card_icons[color])
	draw_widget.visible = false
	table_game.joker_ongoing = false
	bonus_card_played_successfully("joker")

############################################ SWITCH #########################################################

func start_switch():
	first_switch_card_is_selected = true
	table_game.switch_ongoing = true
	highlighter.switch_clicked()

func cancel_switch():
	first_switch_card_is_selected = false
	second_switch_card_is_selected = false
	table_game.switch_ongoing = false
	highlighter.switch_canceled()

func switch_field(field):
	
	if first_switch_card_is_selected:
		switch_first_field(field)
		return
		
	if second_switch_card_is_selected:
		switch_second_field(field)
		return

func switch_first_field(field):
	first_switch_field = field
	if !first_switch_field.get_node("Card").get_groups().has("FieldCard") or field == field_locked_by_player or field == field_locked_by_richard:
		return
	first_switch_card_is_selected = false
	second_switch_card_is_selected = true
	highlighter.switch_first_card_selected()

func switch_second_field(field):
	second_switch_field = field
	if (second_switch_field.get_node("Card").get_groups().has("FieldCard") and field == field_locked_by_player) or (second_switch_field.get_node("Card").get_groups().has("FieldCard") and field == field_locked_by_richard):
		return
	active_bonus_card = "switch"
	bonus_card_playable = true
	table_game.play_card_button.visible = true
	second_switch_card_is_selected = false
	highlighter.switch_second_card_selected()

func execute_switch():
	await switch_fields(first_switch_field, second_switch_field)
	table_game.point_system_controller.calculate_points(table_game.gameboard_fields.find(first_switch_field), played_by)
	table_game.point_system_controller.calculate_points(table_game.gameboard_fields.find(second_switch_field), played_by)
	highlighter.switch_executed()
	bonus_card_played_successfully("switch")

# Swaps cards inside the fields manually
func switch_fields(field1, field2):
	block_panel.visible = true
	var first_tween = create_tween()
	first_tween.tween_property(hand, "position", Vector2(field1.position.x, field1.position.y), 0.4 * table_game.turn_time)
	first_tween.connect("finished", func(): _switch_fields_tween_finished(field1, field2))
	await switch_fields_return1

func _switch_fields_tween_finished(field1, field2):
	await get_tree().create_timer(0.1 * table_game.turn_time).timeout
	var second_tween = create_tween()
	second_tween.tween_property(hand, "position", Vector2(field2.position.x, field2.position.y), 0.4 * table_game.turn_time)
	second_tween.connect("finished", func(): _switch_fields_tween_finished2(field1, field2))
	await switch_fields_return2
	switch_fields_return1.emit()

func _switch_fields_tween_finished2(field1, field2):
	await get_tree().create_timer(0.1 * table_game.turn_time).timeout
	hand.position = hand_return
	switch_fields2(field1, field2)
	block_panel.visible = false
	switch_fields_return2.emit()

func switch_fields2(field1, field2):
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
	table_game.doublepoints_ongoing = true
	highlighter.doublepoints_clicked()

func cancel_doublepoints():
	table_game.doublepoints_ongoing = false
	highlighter.doublepoints_canceled()

func doublepoints_field(field):
	double_field = field
	active_bonus_card = "doublepoints"
	bonus_card_playable = true
	table_game.play_card_button.visible = true
	highlighter.doublepoints_selected()

func execute_doublepoints():
	await create_doublepoints_field(double_field)
	highlighter.doublepoints_executed()
	bonus_card_played_successfully("doublepoints")

func create_doublepoints_field(field):
	block_panel.visible = true
	var first_tween = create_tween()
	first_tween.tween_property(hand, "position", Vector2(field.position.x, field.position.y), 0.8 * table_game.turn_time)
	first_tween.connect("finished", func(): _create_doublepoints_field_tween_finished(field))
	await create_doublepoints_field_return

func _create_doublepoints_field_tween_finished(field):
	await get_tree().create_timer(0.2 * table_game.turn_time).timeout
	hand.position = hand_return
	create_doublepoints_field2(field)
	table_game.point_system_controller.doublepoints_field_positions.append(table_game.gameboard_fields.find(field))
	block_panel.visible = false
	create_doublepoints_field_return.emit()

func create_doublepoints_field2(field):
	
	if table_game.gameboard_fields.find(field) in table_game.point_system_controller.doublepoints_field_positions:
		field.get_node("DoublePoints").get_node("X2").text = "X4"
		return
	
	var doublepoints_node = Control.new()
	doublepoints_node.name = "DoublePoints"
	doublepoints_node.custom_minimum_size = Vector2(35, 35)
	doublepoints_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var border_panel = Panel.new()
	border_panel.name = "Border"
	border_panel.custom_minimum_size = Vector2(37, 37)
	border_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	border_panel.add_theme_stylebox_override("panel", load("res://segments/tavern_game/gameboard_visual_styles/bonus_card_border.tres"))
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
	table_game.lock_ongoing = true
	highlighter.lock_clicked()

func cancel_lock():
	table_game.lock_ongoing = false
	highlighter.lock_canceled()

func lock_field(field):
	field_locked_by_player = field
	active_bonus_card = "lock"
	bonus_card_playable = true
	table_game.play_card_button.visible = true
	highlighter.lock_selected()

func execute_lock():
	await create_locked_field(field_locked_by_player)
	if !field_locked_by_player.get_node("Card").get_groups().has("FieldCard"):
		confirmed_locked_field_position = table_game.gameboard_fields.find(field_locked_by_player)
		locked_by = "Player"
	if field_locked_by_player == field_locked_by_richard:
		remove_lock()
	else:
		highlighter.lock_executed()
	bonus_card_played_successfully("lock")

func richard_execute_lock():
	await create_locked_field(field_locked_by_richard)
	if !field_locked_by_richard.get_node("Card").get_groups().has("FieldCard"):
		richard_confirmed_locked_field_position = table_game.gameboard_fields.find(field_locked_by_richard)
		locked_by2 = "Richard"
	if field_locked_by_player == field_locked_by_richard:
		remove_lock()
	print("finished executing")

func create_locked_field(field):
	block_panel.visible = true
	var first_tween = create_tween()
	first_tween.tween_property(hand, "position", Vector2(field.position.x, field.position.y), 0.8 * table_game.turn_time)
	first_tween.connect("finished", func(): _create_locked_field_tween_finished(field))
	await create_locked_field_return

func _create_locked_field_tween_finished(field):
	await get_tree().create_timer(0.2 * table_game.turn_time).timeout
	hand.position = hand_return
	create_locked_field2(field)
	block_panel.visible = false
	print("finished creating")
	create_locked_field_return.emit()

func create_locked_field2(field):
	var locked_node = Control.new()
	if played_by == "Player":
		locked_node.name = "LockedByPlayer"
	if played_by == "Richard":
		locked_node.name = "LockedByRichard"
	locked_node.custom_minimum_size = Vector2(35, 35)
	locked_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var border_panel = Panel.new()
	border_panel.name = "Border"
	border_panel.custom_minimum_size = Vector2(37, 37)
	border_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	border_panel.add_theme_stylebox_override("panel", load("res://segments/tavern_game/gameboard_visual_styles/bonus_card_border.tres"))
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

func remove_lock():
	field_locked_by_player.get_node("LockedByPlayer").queue_free()
	field_locked_by_richard.get_node("LockedByRichard").queue_free()
	confirmed_locked_field_position = -1
	richard_confirmed_locked_field_position = -1
	field_locked_by_player = null
	field_locked_by_richard = null

###########################################################################################################

func confirm_bonus_card_play():
	return bonus_card_playable

func execute_bonus_card():
	if active_bonus_card == "joker":
		await execute_joker()
	elif active_bonus_card == "switch":
		await execute_switch()
	elif active_bonus_card == "doublepoints":
		await execute_doublepoints()
	elif active_bonus_card == "lock":
		await execute_lock()

func bonus_card_played_successfully(type):
	await get_tree().create_timer(1.1 * table_game.turn_time).timeout # to ensure hand animations finish moving
	highlighter.bonus_card_played()
	table_game.bonus_cards[type].queue_free()
	table_game.bonus_cards.erase(type)
	table_game.player_deck.get_child(len(table_game.player_deck.get_children())-2).queue_free()
	table_game.player_played_bonus_card = true
	table_game.switch_ongoing = false
	table_game.joker_ongoing = false
	table_game.doublepoints_ongoing = false
	table_game.lock_ongoing = false
	table_game.bonus_card_played = true
	if table_game.normal_card_played:
		table_game.end_turn()

func currently_playing(player):
	played_by = player
	if played_by == "Player":
		hand = $"../PlayerHand"
		hand_return = Vector2(130, 200)
	elif played_by == "Richard":
		hand = $"../RichardHand"
		hand_return = Vector2(70, -80)

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
