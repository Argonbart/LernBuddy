extends Node

signal table_game_started()
signal table_game_exited()
signal player_prompt(text)

@onready var deck = $"../TableGame/Deck"
@onready var player_hand_cards = $"../TableGame/PlayerCards"
@onready var player_edit_cards = $"../TableGame/EditCards"
@onready var played_cards = $"../TableGame/PlayCards"
@onready var game_board = $"../TableGame/GameBoard"
@onready var played_cards_big_view = $"../TableGame/BigCardsOnField"

@onready var player : Node2D
@onready var richard = $"../Richard/RichardSprite"
@onready var camera = $"../Camera"
@onready var table_game = $"../TableGame"
@onready var play_card_button = $"../TableGame/GameBoard/PlayCardButton"
@onready var win_screen = $"../PlayerWon"
@onready var win_screen_button = $"../PlayerWon/Button"
@onready var ergebnis_screen = $"../ErgebnisScreen"

var draw_card_button = null
var deck_cards = []
var player_hand_counter = 0

var deck_empty
var player_hand_empty

var special_card_played = false
var special_card_hand = null
var special_card_edit = null
var special_card_corner = null
var special_card_style_box

var colors
var style_boxes
var game_field_positions

var player_nearby
var game_ongoing

var game_field_position_selected = null
var game_field_last_selected = null

var default_button = Button.new()
var last_button = default_button
var active_card = null
var richards_turn = false

var player_cards_array = []
var edit_cards_array = []
var grid_empty = [true, true, true, true, true, true, true, true, true]
var grid_cards = [null, null, null, null, null, null, null, null, null]
var grid_big_cards = [null, null, null, null, null, null, null, null, null]

var richard_dialogue_json_as_dict
var richard_dialogue_response_counter
var color_to_idx = {"red": 0, "yellow": 1, "green": 2, "blue": 3, "grey": 4}

var card_effects_json_as_dict
var play_extra_card = false

func _ready():
	player = get_tree().get_root().get_node("Player")
	table_game.visible = false
	player_nearby = false
	game_ongoing = false
	initiate_game_field()

func initiate_game_field():
	initiate_style_boxes()
	initiate_table_buttons()
	generate_deck(8)
	create_special_card()
	initiate_json_files()

func initiate_json_files():
	richard_dialogue_json_as_dict = JSON.parse_string(FileAccess.get_file_as_string("res://dialogue/richard_dialogue.json"))
	card_effects_json_as_dict = JSON.parse_string(FileAccess.get_file_as_string("res://dialogue/bonus_card_effects.json"))
	richard_dialogue_response_counter = 0

func next_richard_response():
	if richard_dialogue_json_as_dict and richard_dialogue_response_counter < len(richard_dialogue_json_as_dict):
		var response = {"text": richard_dialogue_json_as_dict[richard_dialogue_response_counter].text, "style_box": style_boxes[color_to_idx[richard_dialogue_json_as_dict[richard_dialogue_response_counter].color]]}
		richard_dialogue_response_counter = richard_dialogue_response_counter + 1
		return response
	else:
		return {"text": "No more responses for Richard available.", "style_box": style_boxes[0]}

func next_card_effect():
	return card_effects_json_as_dict[randi_range(0,len(card_effects_json_as_dict)-1)]

func _process(_delta):
	if player_nearby and !game_ongoing and Input.is_action_just_pressed("interact"):
		game_ongoing = true
		table_game_started.emit()
		start_game()
	
	if game_ongoing and Input.is_action_just_pressed("esc"):
		win_screen_button.visible = false
		ergebnis_screen.visible = false
		game_ongoing = false
		table_game_exited.emit()
		stop_game()
	
	if player_hand_counter == 0:
		player_hand_empty = true
	else:
		player_hand_empty = false
	
	if deck_empty and player_hand_empty:
		player_hand_counter = -1

func start_game():
	table_game.visible = true
	player.visible = false
	
func stop_game():
	table_game.visible = false
	player.visible = true

func _on_body_entered(body):
	if body.name == "Player":
		player_nearby = true

func _on_body_exited(body):
	if body.name == "Player":
		player_nearby = false

func initiate_style_boxes():
	colors = {Color("#ea4d53") : "red", Color("#ebbc6d"):  "yellow", Color("#328948") : "green", Color("#554dc9") : "blue", Color("#989595") : "grey"}
	style_boxes = []
	for color in colors.keys():
		var new_style_box = StyleBoxFlat.new()
		new_style_box.bg_color = color
		new_style_box.border_width_left = 1
		new_style_box.border_width_top = 1
		new_style_box.border_width_right = 1
		new_style_box.border_width_bottom = 1
		new_style_box.border_color = Color("#000000")
		style_boxes.append(new_style_box)
	special_card_style_box = StyleBoxFlat.new()
	special_card_style_box.bg_color = Color.AQUAMARINE
	special_card_style_box.border_width_left = 1
	special_card_style_box.border_width_top = 1
	special_card_style_box.border_width_right = 1
	special_card_style_box.border_width_bottom = 1
	special_card_style_box.border_color = Color("#000000")

func initiate_table_buttons():
	game_field_positions = [Vector2(31, 8), Vector2(83, 8), Vector2(135, 8), Vector2(31, 52), Vector2(83, 52), Vector2(135, 52), Vector2(31, 96), Vector2(83, 96), Vector2(135, 96)]
	for pos in game_field_positions:
		var new_button = Button.new()
		new_button.custom_minimum_size = Vector2(40, 40)
		new_button.position = pos
		new_button.flat = true
		new_button.connect("focus_entered", func(): _button_selected_on(new_button))
		new_button.connect("focus_exited", func(): _button_selected_off())
		new_button.connect("mouse_entered", func(): _hovering_over_button(new_button))
		new_button.connect("mouse_exited", func(): _stop_hovering_over_button(new_button))
		game_board.add_child(new_button)
	play_card_button.connect("button_down", func(): _play_card())
	win_screen_button.connect("pressed", func(): _show_result_screen())

func _show_result_screen():
	win_screen.visible = false
	ergebnis_screen.visible = true

func generate_deck(deck_length):
	for i in range(deck_length):
		var white_card = Panel.new()
		var white_style_box = StyleBoxFlat.new()
		white_style_box.bg_color = Color.WHITE
		white_style_box.border_width_left = 1
		white_style_box.border_width_top = 1
		white_style_box.border_width_right = 1
		white_style_box.border_width_bottom = 1
		white_style_box.border_color = Color("#000000")
		white_card.custom_minimum_size = Vector2(40, 40)
		white_card.position = Vector2(0 + 2*i, 0 - 2*i)
		white_card.add_theme_stylebox_override("panel", white_style_box)
		white_card.visible = true
		deck.add_child(white_card)
		deck_cards.append(white_card)
	var new_draw_button = Button.new()
	new_draw_button.size = Vector2(40, 40)
	new_draw_button.position = Vector2(0 + 2 * (deck_length-1), 0 - 2 * (deck_length-1))
	new_draw_button.flat = true
	new_draw_button.set_script("res://scripts/button.gd")
	deck.add_child(new_draw_button)
	draw_card_button = new_draw_button
	draw_card_button.connect("button_up", func(): _draw_card_button_up())
	if deck_length > 0:
		deck_empty = false

func draw_card():
	if !special_card_played:
		return
	if deck_empty:
		return
	var new_style_box = style_boxes[randi_range(0,len(colors)-1)]
	var card_text = choose_card_text(colors[new_style_box.bg_color])
	var new_hand_card = _add_hand_card(new_style_box)
	var new_edit_card = _add_edit_card(new_style_box, card_text)
	var new_button = _add_card_button()
	new_button.connect("pressed", func(): _click_card(new_edit_card))
	new_hand_card.add_child(new_button)
	player_hand_cards.add_child(new_hand_card)
	player_edit_cards.add_child(new_edit_card)
	player_cards_array.append(new_hand_card)
	player_hand_counter = player_hand_counter + 1
	edit_cards_array.append(new_edit_card)
	deck_cards[-1].queue_free()
	deck_cards.pop_back()
	draw_card_button.position = Vector2(draw_card_button.position.x - 2, draw_card_button.position.y + 2)
	if len(deck_cards) == 0:
		draw_card_button.queue_free()
		deck_empty = true

func choose_card_text(color):
	var card_text = ""
	if color == "red":  # red = Emotionen
		card_text = "EMOTIONEN\nWie fühlst du dich in Bezug auf das zu reflektierende Thema? Welche positiven oder negativen Gefühle empfindest du?\n[ Fang an zu tippen.. ]"
	if color == "yellow":  # white = Fakten
		card_text = "FAKTEN\nWelche für deine Reflektion relevanten Fakten, Daten, Informationen fallen dir ein?\n[ Fang an zu tippen.. ]"
	if color == "green":  # green = Optimismus
		card_text = "OPTIMISMUS\nWelche Vorteile oder Möglichkeiten ergeben sich?\n[ Fang an zu tippen.. ]"
	if color == "blue":  # blue = Kreativität
		card_text = "KREATIVITÄT\nWelche verrückten oder eher fernen Dinge fallen die zu deinem Thema ein?\n[ Fang an zu tippen.. ]"
	if color == "grey":  # purple = Bonus
		var card_effect = next_card_effect()
		var effect_text = card_effect.values()[0]
		card_text = effect_text
	return card_text

func _add_hand_card(style_box_type):
	var new_card_hand = Panel.new()
	new_card_hand.custom_minimum_size = Vector2(40, 40)
	new_card_hand.size_flags_horizontal = Control.SIZE_SHRINK_CENTER | Control.SIZE_EXPAND
	new_card_hand.add_theme_stylebox_override("panel", style_box_type)
	return new_card_hand

func _add_edit_card(style_box, card_text):
	var new_card_edit = Panel.new()
	var new_text_edit = TextEdit.new()
	new_card_edit.custom_minimum_size = Vector2(100, 100)
	new_card_edit.position = Vector2(2.5, 3.0)
	new_card_edit.add_theme_stylebox_override("panel", style_box)
	new_card_edit.visible = false
	new_text_edit.scale = Vector2(0.05, 0.05)
	new_text_edit.custom_minimum_size = Vector2(1900, 1900)
	new_text_edit.position = Vector2(3.0, 2.0)
	new_text_edit.placeholder_text = card_text
	if style_box.bg_color in colors and colors[style_box.bg_color] == "grey":
		new_text_edit.text = card_text
		new_text_edit.add_theme_color_override("font_readonly_color", Color.BLACK)
	new_text_edit.add_theme_color_override("background_color", style_box.bg_color)
	new_text_edit.add_theme_color_override("font_color", Color.BLACK)
	new_text_edit.add_theme_color_override("font_placeholder_color", Color.BLACK)
	new_text_edit.add_theme_font_size_override("font_size", 140)
	new_text_edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	if style_box.bg_color in colors:
		new_text_edit.editable = colors[style_box.bg_color] != "grey"
	new_card_edit.add_child(new_text_edit)
	return new_card_edit

func _add_card_button():
	var new_button = Button.new()
	new_button.custom_minimum_size = Vector2(40, 40)
	new_button.flat = true
	return new_button

func _click_card(edit_card):
	if !richards_turn:
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

func play_card_on_field_allowed(played_card, game_field_position):
	var red = colors.values()[0]
	var yellow = colors.values()[1]
	var green = colors.values()[2]
	var blue = colors.values()[3]
	var grey = colors.values()[4]
	if played_card.get_theme_stylebox("panel") == special_card_style_box:
		return true
	var played_card_color = colors[played_card.get_theme_stylebox("panel").bg_color]
	if !grid_cards[find_grid_position(game_field_position)]:
		return true
	var field_card_color = colors[grid_cards[find_grid_position(game_field_position)].get_theme_stylebox("panel").bg_color]
	if(played_card_color == grey or field_card_color == grey):
		return true
	if(played_card_color == field_card_color):
		return true
	if(played_card_color == yellow and field_card_color == blue):
		return true
	if(played_card_color == green and field_card_color == yellow):
		return true
	if(played_card_color == red and field_card_color == green):
		return true
	if(played_card_color == blue and field_card_color == red):
		return true
	return false

func find_grid_position(gamefield_position):
	return game_field_positions.find(gamefield_position)

func _play_card():
	if play_card_on_field_allowed(active_card, game_field_last_selected):
		_execute_play_card()
	else:
		print("This move is not allowed!")

func _add_field_card(style_box):
	var new_field_card = Panel.new()
	var new_field_card_label = Label.new()
	new_field_card.custom_minimum_size = Vector2(40, 40)
	new_field_card.add_theme_stylebox_override("panel", style_box)
	new_field_card.position = game_field_last_selected
	new_field_card.visible = true
	new_field_card_label.custom_minimum_size = Vector2(720, 720)
	new_field_card_label.add_theme_color_override("font_color", Color.BLACK)
	new_field_card_label.position = Vector2(2, 2)
	new_field_card_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	new_field_card_label.scale = Vector2(0.05, 0.05)
	new_field_card_label.add_theme_font_size_override("font_size", 60)
	new_field_card_label.text = active_card.get_child(0).text
	new_field_card.add_child(new_field_card_label)
	return new_field_card

func _add_field_card_big_view(style_box):
	var new_big_card = Panel.new()
	var new_big_card_label = Label.new()
	new_big_card.custom_minimum_size = Vector2(100, 100)
	new_big_card.position = Vector2(2.5, 3.0)
	new_big_card.add_theme_stylebox_override("panel", style_box)
	new_big_card.visible = false
	new_big_card_label.custom_minimum_size = Vector2(1900, 1900)
	new_big_card_label.position = Vector2(3.0, 2.0)
	new_big_card_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	new_big_card_label.scale = Vector2(0.05, 0.05)
	new_big_card_label.add_theme_font_size_override("font_size", 140)
	new_big_card_label.text = active_card.get_child(0).text
	new_big_card_label.add_theme_color_override("font_color", Color.BLACK)
	new_big_card.add_child(new_big_card_label)
	return new_big_card

func _execute_play_card():
	if !special_card_played:
		special_card_corner.get_child(0).text = special_card_edit.get_child(0).text
		special_card_played = true
		special_card_hand.queue_free()
		special_card_edit.queue_free()
		special_card_corner.visible = true
		play_card_button.visible = false
		return
	
	if game_field_last_selected != null and active_card != null:
		play_card_button.visible = false
		var play_card_style_box = active_card.get_theme_stylebox("panel")
		var new_field_card = _add_field_card(play_card_style_box)
		var new_field_card_big_view = _add_field_card_big_view(play_card_style_box)
		played_cards.add_child(new_field_card)
		played_cards_big_view.add_child(new_field_card_big_view)
		var player_card_number = edit_cards_array.find(active_card)
		player_cards_array[player_card_number].queue_free()
		player_hand_counter = player_hand_counter - 1
		edit_cards_array[player_card_number].queue_free()
		
		var field_nr = game_field_positions.find(game_field_last_selected)	
		grid_cards[field_nr] = new_field_card
		grid_empty[field_nr] = false
		grid_big_cards[field_nr] = new_field_card_big_view
		
		if colors[play_card_style_box.bg_color] == "grey":
			if active_card.get_child(0).text == "Ziehe zwei Karten.":
				var timer = Timer.new()
				add_child(timer)
				timer.wait_time = 0.3
				timer.one_shot = true
				timer.timeout.connect(func(): _draw_first_card_timer_timeout())
				timer.start()
			if active_card.get_child(0).text == "Lege eine weitere Karte.":
				play_extra_card = true
			if player_hand_counter > 0:
				active_card = null
				return
			play_extra_card = false
		
		if play_extra_card:
			play_extra_card = false
			active_card = null
			return
		
		richard_move(active_card.get_child(0).text)
		richards_turn = true
		
		active_card = null
	else:
		print("no field or card selected")

func _draw_first_card_timer_timeout():
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.3
	timer.one_shot = true
	timer.timeout.connect(func(): _draw_second_card_timer_timeout())
	timer.start()
	draw_card()

func _draw_second_card_timer_timeout():
	draw_card()

func richard_move(text):
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 1
	timer.one_shot = true
	timer.timeout.connect(func(): _richard_timer_timeout(text))
	timer.start()

func _richard_timer_timeout(text):
	richard_move_2(text)
	richards_turn = false

func richard_move_2(_text):
	var richard_next_json = next_richard_response()
	var richard_text = richard_next_json["text"]
	var richard_card_play_position = randi_range(0,len(grid_cards)-1)
	var richard_play_card_style_box = richard_next_json["style_box"]
	var new_richard_field_card = _add_richard_field_card(richard_play_card_style_box, richard_card_play_position, richard_text)
	var new_richard_field_card_big_view = _add_richard_field_card_big_view(richard_play_card_style_box, richard_text)
	played_cards.add_child(new_richard_field_card)
	played_cards_big_view.add_child(new_richard_field_card_big_view)
	grid_cards[richard_card_play_position] = new_richard_field_card
	grid_empty[richard_card_play_position] = false
	grid_big_cards[richard_card_play_position] = new_richard_field_card_big_view
	if player_hand_counter == -1:
			win_screen.visible = true

func _add_richard_field_card(style_box, field_position, richard_text):
	var new_field_card = Panel.new()
	var new_field_card_label = Label.new()
	new_field_card.custom_minimum_size = Vector2(40, 40)
	new_field_card.add_theme_stylebox_override("panel", style_box)
	new_field_card.position = game_field_positions[field_position]
	new_field_card.visible = true
	new_field_card_label.custom_minimum_size = Vector2(720, 720)
	new_field_card_label.add_theme_color_override("font_color", Color.BLACK)
	new_field_card_label.position = Vector2(2, 2)
	new_field_card_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	new_field_card_label.scale = Vector2(0.05, 0.05)
	new_field_card_label.add_theme_font_size_override("font_size", 60)
	new_field_card_label.text = richard_text
	new_field_card.add_child(new_field_card_label)
	return new_field_card

func _add_richard_field_card_big_view(style_box, richard_text):
	var new_big_card = Panel.new()
	var new_big_card_label = Label.new()
	new_big_card.custom_minimum_size = Vector2(100, 100)
	new_big_card.position = Vector2(2.5, 3.0)
	new_big_card.add_theme_stylebox_override("panel", style_box)
	new_big_card.visible = false
	new_big_card_label.custom_minimum_size = Vector2(1900, 1900)
	new_big_card_label.position = Vector2(3.0, 2.0)
	new_big_card_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	new_big_card_label.scale = Vector2(0.05, 0.05)
	new_big_card_label.add_theme_font_size_override("font_size", 140)
	new_big_card_label.text = richard_text
	new_big_card_label.add_theme_color_override("font_color", Color.BLACK)
	new_big_card.add_child(new_big_card_label)
	return new_big_card

func _draw_card_button_up():
	if !richards_turn:
		draw_card()

func _on_chat_api_next_response(message, npc_id):
	if npc_id == 10:
		richard_move(message)
		richards_turn = false

func _add_corner_card(style_box, card_text):
	var new_card_edit = Panel.new()
	var new_text_edit = TextEdit.new()
	new_card_edit.custom_minimum_size = Vector2(20, 20)
	new_card_edit.position = Vector2(240, -20)
	new_card_edit.add_theme_stylebox_override("panel", style_box)
	new_card_edit.visible = false
	new_text_edit.scale = Vector2(0.05, 0.05)
	new_text_edit.custom_minimum_size = Vector2(300, 300)
	new_text_edit.position = Vector2(3.0, 2.0)
	new_text_edit.placeholder_text = card_text
	new_text_edit.add_theme_color_override("background_color", style_box.bg_color)
	new_text_edit.add_theme_color_override("font_color", Color.BLACK)
	new_text_edit.add_theme_color_override("font_placeholder_color", Color.BLACK)
	new_text_edit.add_theme_font_size_override("font_size", 40)
	new_text_edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	new_card_edit.add_child(new_text_edit)
	return new_card_edit

func create_special_card():
	var new_style_box = special_card_style_box
	var card_text = "Formuliere einen \"Ich\"-Satz zu der Thematik, zu dem du gerne neue Perspektiven einnehmen möchtest. Beispiel: Mein Lernfortschritt kommt nicht so gut voran wie erwünscht.\n[ Fang an zu tippen.. ]"
	var new_hand_card = _add_hand_card(new_style_box)
	var new_edit_card = _add_edit_card(new_style_box, card_text)
	var new_corner_card = _add_corner_card(special_card_style_box, card_text)
	var new_button = _add_card_button()
	new_button.connect("pressed", func(): _click_card(new_edit_card))
	new_hand_card.add_child(new_button)
	player_hand_cards.add_child(new_hand_card)
	player_edit_cards.add_child(new_edit_card)
	game_board.add_child(new_corner_card)
	special_card_hand = new_hand_card
	special_card_edit = new_edit_card
	special_card_corner = new_corner_card
