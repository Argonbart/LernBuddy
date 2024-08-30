extends Node


@onready var deck = $"../TableGame/Deck"
@onready var player_hand_cards = $"../TableGame/PlayerCards"
@onready var played_cards = $"../TableGame/PlayCards"
@onready var played_cards_big_view = $"../TableGame/BigCardsOnField"
@onready var player_edit_cards = $"../TableGame/EditCards"


@onready var richard = $"../Richard/RichardSprite"
@onready var camera = $"../Camera"
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
	initiate_game_field()

func initiate_game_field():
	create_special_card()
	initiate_json_files()

func initiate_json_files():
	richard_dialogue_json_as_dict = JSON.parse_string(FileAccess.get_file_as_string("res://ressources/dialogues/richard_dialogue.json"))
	card_effects_json_as_dict = JSON.parse_string(FileAccess.get_file_as_string("res://ressources/dialogues/bonus_card_effects.json"))
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
	
	
	if player_hand_counter == 0:
		player_hand_empty = true
	else:
		player_hand_empty = false
	
	if deck_empty and player_hand_empty:
		player_hand_counter = -1

func _show_result_screen():
	win_screen.visible = false
	ergebnis_screen.visible = true

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

func _draw_card_button_up():
	if !richards_turn:
		draw_card()

func _api_response(message, npc):
	if npc == "Richard":
		richard_move(message)
		richards_turn = false
