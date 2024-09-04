extends CharacterBody2D

@onready var table_game = $"../TableGame"

var free_fields = []
var richard_hand_cards = ["red", "red", "yellow", "yellow", "green", "green", "blue", "blue"]

func _ready():
	table_game.connect("player_played_card", func(): _player_played_card())

func _process(_delta):
	self.get_child(0).play("idle")

func _player_played_card():
	update_free_fields()
	#await get_tree().create_timer(1.0).timeout
	var next_move = calculate_next_move()
	richard_play_card(next_move["field"], next_move["color"], next_move["text"])

func update_free_fields():
	free_fields.clear()
	for field in table_game.gameboard_fields:
		if !table_game.find_field_card(field):
			free_fields.append(field)

func richard_play_card(field_position, color, text):
	table_game.create_field_card(field_position, color, table_game.card_icons[color], text, "Text", false)

# Current "Strategy": Random color on a random free field
func calculate_next_move():
	var next_card_idx = randi_range(0, len(richard_hand_cards)-1)
	var random_color_to_play = richard_hand_cards.pop_at(next_card_idx)
	var random_field_to_play = table_game.gameboard_fields.find(free_fields[randi_range(0, len(free_fields)-1)])
	var static_richard_text = "Richard Card Text"
	return {"field": random_field_to_play, "color": random_color_to_play, "text": static_richard_text}

#func _api_response(message, npc):
	#if npc == "Richard":
		# # Generate response
		#pass
