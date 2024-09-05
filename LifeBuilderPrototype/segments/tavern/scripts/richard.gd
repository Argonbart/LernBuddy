extends CharacterBody2D

signal game_finished()

@onready var table_game = $"../TableGame"

var free_fields = []
var richard_hand_cards = ["red", "red", "yellow", "yellow", "green", "green", "blue", "blue"]
var color_to_play

func _ready():
	table_game.connect("player_played_card", func(): _player_played_card())

func _process(_delta):
	self.get_child(0).play("idle")

func _player_played_card():
	update_free_fields()
	table_game.get_node("RichardsTurnPanel").visible = true
	await get_tree().create_timer(1.0).timeout
	table_game.get_node("RichardsTurnPanel").visible = false
	var next_move = calculate_next_move()
	richard_play_card(next_move["field"], next_move["color"], next_move["text"])

func update_free_fields():
	free_fields.clear()
	for field in table_game.gameboard_fields:
		if !table_game.find_field_card(field):
			free_fields.append(field)

func richard_play_card(field_position, color, text):

	# might be relevant for bonus card play
	#
	# bonus_card_controller.currently_playing("Player")
	# bonus_card_controller.execute_bonus_card()
	#
	# Check for lock
	
	if field_position == table_game.bonus_card_controller.confirmed_locked_field_position:
		if table_game.bonus_card_controller.locked_by != "Richard":
			_player_played_card()
			print("repeating")
			return
		#else:
			# remove locked field
			#table_game.selected_field.get_node("Locked").queue_free()
			#table_game.bonus_card_controller.confirmed_locked_field_position = -1
	
	table_game.create_field_card(field_position, color, table_game.card_icons[color], text, "Text", false)
	color_to_play = null
	
	# Calculate points
	table_game.point_system_controller.calculate_points(field_position, "Richard")
	
	if len(richard_hand_cards) == 0:
		game_finished.emit()

# Current "Strategy": Random color on a random free field
func calculate_next_move():
	var next_card_idx = randi_range(0, len(richard_hand_cards)-1)
	var random_color_to_play = get_next_color(next_card_idx)
	var random_field_to_play = table_game.gameboard_fields.find(free_fields[randi_range(0, len(free_fields)-1)])
	var static_richard_text = "Richard Card Text"
	return {"field": random_field_to_play, "color": random_color_to_play, "text": static_richard_text}

func get_next_color(idx):
	if color_to_play == null:
		var next_color = richard_hand_cards.pop_at(idx)
		color_to_play = next_color
		return next_color
	else:
		return color_to_play

#func _api_response(message, npc):
	#if npc == "Richard":
		# # Generate response
		#pass
