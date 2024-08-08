extends Node

signal table_game_started()
signal table_game_exited()
signal player_prompt(text)

var white_card_path = "res://scenes/cards/white_card.tres"
var green_card_path = "res://scenes/cards/green_card.tres"
var red_card_path = "res://scenes/cards/red_card.tres"
var blue_card_path = "res://scenes/cards/blue_card.tres"
var card_paths = [white_card_path, green_card_path, red_card_path, blue_card_path]
var card_colors = ["white", "green", "red", "blue"]
var game_field_positions = [Vector2(31, 8), Vector2(83, 8), Vector2(135, 8), Vector2(31, 52), Vector2(83, 52), Vector2(135, 52), Vector2(31, 96), Vector2(83, 96), Vector2(135, 96)]
var game_field_position_selected = null
var game_field_last_selected = null

var default_button = Button.new()
var last_button = default_button
var active_card = null

var player_cards_array = []
var edit_cards_array = []
var grid_empty = [true, true, true, true, true, true, true, true, true]
var grid_cards = [null, null, null, null, null, null, null, null, null]
var grid_big_cards = [null, null, null, null, null, null, null, null, null]

@onready var player = $"../Player"
@onready var camera = $"../Camera"
@onready var table_game = $"../TableGame"
@onready var play_card_button = $"../TableGame/GameBoard/PlayCardButton"

var player_nearby = false
var game_ongoing = false

func _ready():
	table_game.visible = false
	create_table_buttons()
	play_card_button.connect("button_down", func(): _play_card())

func _process(_delta):
	if player_nearby and Input.is_action_just_pressed("interact"):
		table_game_started.emit()
		if game_ongoing:
			return
		game_ongoing = true
		start_game()
	
	if game_ongoing and Input.is_action_just_pressed("esc"):
		table_game_exited.emit()
		game_ongoing = false
		stop_game()

func _on_body_entered(body):
	if body.name == "Player":
		player_nearby = true

func _on_body_exited(body):
	if body.name == "Player":
		player_nearby = false

func start_game():
	table_game.visible = true
	player.visible = false
	
func stop_game():
	table_game.visible = false
	player.visible = true

func _on_button_button_up():
	draw_card()

func draw_card():
	var new_card_hand = Panel.new()
	var new_card_edit = Panel.new()
	var new_button = Button.new()
	var new_text_edit = TextEdit.new()
	var new_color = randi_range(0,len(card_paths)-1)
	var style_box = load(card_paths[new_color])
	
	new_card_hand.custom_minimum_size = Vector2(40, 40)
	new_card_hand.size_flags_horizontal = Control.SIZE_SHRINK_CENTER | Control.SIZE_EXPAND
	new_card_hand.add_theme_stylebox_override("panel", style_box)
	
	new_card_edit.custom_minimum_size = Vector2(100, 100)
	new_card_edit.position = Vector2(2.5, 3.0)
	new_card_edit.add_theme_stylebox_override("panel", style_box)
	new_card_edit.visible = false
	new_text_edit.scale = Vector2(0.05, 0.05)
	new_text_edit.custom_minimum_size = Vector2(1900, 1900)
	new_text_edit.position = Vector2(3.0, 2.0)
	new_text_edit.placeholder_text = "Write your reflection here.."
	new_text_edit.add_theme_color_override("background_color", style_box.bg_color)
	if new_color == 0 or new_color == 1:
		new_text_edit.add_theme_color_override("font_color", Color.BLACK)
		new_text_edit.add_theme_color_override("font_placeholder_color", Color.BLACK)
	else:
		new_text_edit.add_theme_color_override("font_color", Color.WHITE)
		new_text_edit.add_theme_color_override("font_placeholder_color", Color.WHITE)
	new_text_edit.add_theme_font_size_override("font_size", 140)
	new_card_edit.add_child(new_text_edit)
	
	new_button.connect("pressed", func(): _click_card(new_card_edit))
	new_button.custom_minimum_size = Vector2(40, 40)
	new_button.flat = true
	new_card_hand.add_child(new_button)
	
	table_game.get_child(1).add_child(new_card_hand)
	table_game.get_child(2).add_child(new_card_edit)
	
	player_cards_array.append(new_card_hand)
	edit_cards_array.append(new_card_edit)

func _click_card(edit_card):
	for card in edit_card.get_parent().get_children():
		if card == edit_card:
			edit_card.visible = !edit_card.visible
			if edit_card.visible:
				active_card = edit_card
				if game_field_position_selected == null:
					play_card_button.visible = false
			else:
				active_card = null
				play_card_button.visible = false
		else:
			card.visible = false

func create_table_buttons():
	for pos in game_field_positions:
		var new_button = Button.new()
		new_button.custom_minimum_size = Vector2(40, 40)
		new_button.position = pos
		new_button.flat = true
		new_button.connect("focus_entered", func(): _button_selected_on(new_button))
		new_button.connect("focus_exited", func(): _button_selected_off())
		new_button.connect("mouse_entered", func(): _hovering_over_button(new_button))
		new_button.connect("mouse_exited", func(): _stop_hovering_over_button(new_button))
		table_game.get_child(4).add_child(new_button)

func _button_selected_on(button):
	if active_card:
		game_field_position_selected = button
		game_field_last_selected = button.position
		play_card_button.visible = true

func _button_selected_off():
	game_field_position_selected = null

func _hovering_over_button(button):
	var grid_idx = game_field_positions.find(button.position)
	if !grid_empty[grid_idx]:
		if grid_big_cards[grid_idx]:
				grid_big_cards[grid_idx].visible = true

func _stop_hovering_over_button(button):
	var grid_idx = game_field_positions.find(button.position)
	if !grid_empty[grid_idx]:
		if grid_big_cards[grid_idx]:
				grid_big_cards[grid_idx].visible = false

func _play_card():
	if game_field_last_selected != null and active_card != null:
		var player_card_number = edit_cards_array.find(active_card)
		play_card_button.visible = false
		var new_card_play = Panel.new()
		var new_label = Label.new()
		var style_box = active_card.get_theme_stylebox("panel")
		var new_color = style_box.bg_color
		new_card_play.custom_minimum_size = Vector2(40, 40)
		new_card_play.add_theme_stylebox_override("panel", style_box)
		if new_color == Color(1, 1, 1, 1) or new_color == Color(0, 0.498, 0, 1):
			new_label.add_theme_color_override("font_color", Color.BLACK)
		else:
			new_label.add_theme_color_override("font_color", Color.WHITE)
		new_card_play.position = game_field_last_selected
		new_card_play.visible = true
		new_label.custom_minimum_size = Vector2(720, 720)
		new_label.position = Vector2(2, 2)
		new_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		new_label.scale = Vector2(0.05, 0.05)
		new_label.add_theme_font_size_override("font_size", 60)
		new_label.text = active_card.get_child(0).text
		new_card_play.add_child(new_label)
		table_game.get_child(3).add_child(new_card_play)
		player_cards_array[player_card_number].queue_free()
		edit_cards_array[player_card_number].queue_free()
		
		var field_nr = game_field_positions.find(game_field_last_selected)	
		grid_cards[field_nr] = new_card_play
		grid_empty[field_nr] = false
		var big_card = Panel.new()
		var big_card_label = Label.new()
		big_card.custom_minimum_size = Vector2(100, 100)
		big_card.position = Vector2(2.5, 3.0)
		big_card.add_theme_stylebox_override("panel", grid_cards[field_nr].get_theme_stylebox("panel"))
		big_card.visible = false
		big_card_label.custom_minimum_size = Vector2(1900, 1900)
		big_card_label.position = Vector2(3.0, 2.0)
		big_card_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		big_card_label.scale = Vector2(0.05, 0.05)
		big_card_label.add_theme_font_size_override("font_size", 140)
		big_card_label.text = active_card.get_child(0).text
		if new_color == Color(1, 1, 1, 1) or new_color == Color(0, 0.498, 0, 1):
			big_card_label.add_theme_color_override("font_color", Color.BLACK)
		else:
			big_card_label.add_theme_color_override("font_color", Color.WHITE)
		big_card.add_child(big_card_label)
		table_game.get_child(5).add_child(big_card)
		grid_big_cards[field_nr] = big_card
		
		player_prompt.emit(active_card.get_child(0).text)
		
		active_card = null
	else:
		print("no field or card selected")

func richard_move(text):
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.5
	timer.one_shot = true
	timer.timeout.connect(func(): _richard_timer_timeout(text))
	timer.start()

func _richard_timer_timeout(text):
	richard_move_2(text)

func richard_move_2(text):
	var richard_text = text
	var richard_card = Panel.new()
	var richard_card_label = Label.new()
	var richard_card_color_idx = randi_range(0,len(card_paths)-1)
	var richard_card_style_box = load(card_paths[richard_card_color_idx])
	var richard_card_color = richard_card_style_box.bg_color
	var richard_card_grid_play_position = randi_range(0,len(grid_cards)-1)
	richard_card.custom_minimum_size = Vector2(40, 40)
	richard_card.add_theme_stylebox_override("panel", richard_card_style_box)
	if richard_card_color == Color(1, 1, 1, 1) or richard_card_color == Color(0, 0.498, 0, 1):
		richard_card_label.add_theme_color_override("font_color", Color.BLACK)
	else:
		richard_card_label.add_theme_color_override("font_color", Color.WHITE)
	richard_card.position = game_field_positions[richard_card_grid_play_position]
	richard_card.visible = true
	richard_card_label.custom_minimum_size = Vector2(720, 720)
	richard_card_label.position = Vector2(2, 2)
	richard_card_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	richard_card_label.scale = Vector2(0.05, 0.05)
	richard_card_label.add_theme_font_size_override("font_size", 60)
	richard_card_label.text = richard_text
	richard_card.add_child(richard_card_label)
	table_game.get_child(3).add_child(richard_card)

	grid_cards[richard_card_grid_play_position] = richard_card
	grid_empty[richard_card_grid_play_position] = false
	var richard_big_card = Panel.new()
	var richard_big_card_label = Label.new()
	richard_big_card.custom_minimum_size = Vector2(100, 100)
	richard_big_card.position = Vector2(2.5, 3.0)
	richard_big_card.add_theme_stylebox_override("panel", richard_card_style_box)
	richard_big_card.visible = false
	richard_big_card_label.custom_minimum_size = Vector2(1900, 1900)
	richard_big_card_label.position = Vector2(3.0, 2.0)
	richard_big_card_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	richard_big_card_label.scale = Vector2(0.05, 0.05)
	richard_big_card_label.add_theme_font_size_override("font_size", 140)
	richard_big_card_label.text = richard_text
	if richard_card_color == Color(1, 1, 1, 1) or richard_card_color == Color(0, 0.498, 0, 1):
		richard_big_card_label.add_theme_color_override("font_color", Color.BLACK)
	else:
		richard_big_card_label.add_theme_color_override("font_color", Color.WHITE)
	richard_big_card.add_child(richard_big_card_label)
	table_game.get_child(5).add_child(richard_big_card)
	grid_big_cards[richard_card_grid_play_position] = richard_big_card


func _on_chat_api_next_response(message, npc_id):
	if npc_id == 10:
		richard_move(message)
