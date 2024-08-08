extends Node

signal table_game_started()
signal table_game_exited()

var white_card_path = "res://scenes/cards/white_card.tres"
var green_card_path = "res://scenes/cards/green_card.tres"
var red_card_path = "res://scenes/cards/red_card.tres"
var blue_card_path = "res://scenes/cards/blue_card.tres"
var card_paths = [white_card_path, green_card_path, red_card_path, blue_card_path]
var card_colors = ["white", "green", "red", "blue"]

var card_buttons = {}
var card_counter = 0
var default_button = Button.new()
var last_button = default_button

@onready var player = $"../Player"
@onready var camera = $"../Camera"
@onready var table_game = $"../TableGame"
@onready var big_cards = $"../TableGame/BigCards"

var player_nearby = false
var game_ongoing = false

func _ready():
	table_game.visible = false

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
	var new_card = Panel.new()
	var new_button = Button.new()
	var next_color = randi_range(0,len(card_paths)-1)
	new_button.connect("pressed", func(): _click_card(new_button, card_colors[next_color]))
	new_card.custom_minimum_size = Vector2(40, 40)
	new_button.custom_minimum_size = Vector2(40, 40)
	new_card.size_flags_horizontal = Control.SIZE_SHRINK_CENTER | Control.SIZE_EXPAND
	var style_box = load(card_paths[next_color])
	new_card.add_theme_stylebox_override("panel", style_box)
	new_card.add_child(new_button)
	table_game.get_child(1).add_child(new_card)
	card_buttons[card_counter] = [card_colors[next_color], new_button]
	card_counter = card_counter + 1
	print(card_buttons)

func _click_card(button, color):
	print(button, last_button)
	if color == "white":
		big_cards.get_child(0).visible = true
		big_cards.get_child(1).visible = false
		big_cards.get_child(2).visible = false
		big_cards.get_child(3).visible = false
	if color == "green":
		big_cards.get_child(0).visible = false
		big_cards.get_child(1).visible = true
		big_cards.get_child(2).visible = false
		big_cards.get_child(3).visible = false
	if color == "red":
		big_cards.get_child(0).visible = false
		big_cards.get_child(1).visible = false
		big_cards.get_child(2).visible = true
		big_cards.get_child(3).visible = false
	if color == "blue":
		big_cards.get_child(0).visible = false
		big_cards.get_child(1).visible = false
		big_cards.get_child(2).visible = false
		big_cards.get_child(3).visible = true
	if button == last_button:
		big_cards.get_child(0).visible = false
		big_cards.get_child(1).visible = false
		big_cards.get_child(2).visible = false
		big_cards.get_child(3).visible = false
		last_button = default_button
	else:
		last_button = button
