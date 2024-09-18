extends CharacterBody2D

signal richard_finished_turn()
signal game_finished()

@onready var table_game = $"../"
@onready var bonus_card_label = $"../RichardsTurnPanel/RichardsBonusCardLabel"
@onready var richard_hand_image = $"../RichardHand"
@onready var richard_hand_with_card_image = $"../RichardHandWithCard"

# arrays
var free_fields = []
var fields_played_by = []
var fields_color = []

# richards cards
var richard_hand_cards = ["red", "red", "yellow", "yellow", "green", "green", "blue", "blue"]
var richard_bonus_cards = []

# bonus cards
var bonus_card_used = false
var joker_counter = 0
var switch_counter = 0
var switch_field_position_needed_for_powermove = -1
var play_doublepoint_field = false

# safed plays
var position_first_pick = -1
var color_first_pick = null
var position_second_pick = -1
var color_second_pick = null

func _process(_delta):
	self.get_child(0).play("idle")

func _ready():
	richard_bonus_cards = generate_random_effects()
	table_game.connect("player_played_card", func(): _player_played_card())

func generate_random_effects():
	var random_effects = ["switch", "doublepoints", "lock"]
	random_effects.shuffle()
	random_effects = random_effects.slice(0,2)
	random_effects.append("joker")
	random_effects.shuffle()
	return random_effects

######################################### PLAYER PLAYED CARD #########################################

func _player_played_card():
	update_fields()
	bonus_card_label.text = ""
	if len(free_fields) == 0 or (len(free_fields) == 1 and table_game.gameboard_fields.find(free_fields[0]) == table_game.bonus_card_controller.confirmed_locked_field_position) or (len(free_fields) == 2 and table_game.gameboard_fields.find(free_fields[0]) == table_game.bonus_card_controller.confirmed_locked_field_position and table_game.gameboard_fields.find(free_fields[1]) == table_game.bonus_card_controller.richard_confirmed_locked_field_position) or (len(free_fields) == 2 and table_game.gameboard_fields.find(free_fields[0]) == table_game.bonus_card_controller.richard_confirmed_locked_field_position and table_game.gameboard_fields.find(free_fields[1]) == table_game.bonus_card_controller.confirmed_locked_field_position):
		game_finished.emit()
		return
	var next_move = calculate_next_move()
	table_game.get_node("RichardsTurnPanel").visible = true
	if bonus_card_used:
		await get_tree().create_timer(1.0).timeout
		bonus_card_used = false
	else:
		await get_tree().create_timer(1.0).timeout
	table_game.get_node("RichardsTurnPanel").visible = false
	
	var first_tween = create_tween()
	table_game.highlighting_controller.card_played()
	get_parent().get_node("RichardsTurnPanel").visible = true
	first_tween.tween_property(richard_hand_with_card_image, "position", Vector2(table_game.gameboard_fields[next_move["field"]].position.x, table_game.gameboard_fields[next_move["field"]].position.y), 0.8 * table_game.turn_time)
	first_tween.connect("finished", func(): _played_card_tween_finished(next_move))

func _played_card_tween_finished(next_move):
	await get_tree().create_timer(0.2 * table_game.turn_time).timeout
	richard_hand_with_card_image.position = Vector2(70, -80)
	richard_play_card(next_move["field"], next_move["color"], next_move["text"])
	get_parent().get_node("RichardsTurnPanel").visible = false
	richard_finished_turn.emit()

func update_fields():
	free_fields.clear()
	fields_played_by.clear()
	fields_color.clear()
	for field in table_game.gameboard_fields:
		if field.get_node("Card").get_groups().has("FieldCard"):
			var border_color_of_card = field.get_node("Card").get_theme_stylebox("panel").border_color
			var color_of_card = table_game.colors[field.get_node("Card").get_theme_stylebox("panel").bg_color]
			if border_color_of_card == table_game.player_color:
				fields_played_by.append("P")
			elif border_color_of_card == table_game.richard_color:
				fields_played_by.append("R")
			else:
				printerr("Invalid in richard")
			fields_color.append(color_of_card)
		else:
			fields_played_by.append("E")
			fields_color.append(null)
			free_fields.append(field)

######################################### RICHARD PLAY CARD #########################################

func richard_play_card(field_position, color, text):
	
	table_game.create_field_card(field_position, color, table_game.card_icons[color], text, "Text", false)
	
	# Calculate points
	table_game.point_system_controller.calculate_points(field_position, "Richard")
	
	# End game
	if (len(table_game.player_hand_cards.get_children()) == 0 and table_game.bonus_cards.has("joker")) or (len(richard_hand_cards) == 0):
		game_finished.emit()

######################################### CALCULATE MOVE #########################################

# Current "Strategy": More Complex
func calculate_next_move():
	
	# reset var for calculation
	var return_field = -1
	var return_color = null
	var return_text = "Richard plays card"
	
	# reset output var
	position_first_pick = -1
	color_first_pick = null
	position_second_pick = -1
	color_second_pick = null
	
	# prepare all relevant lines
	var player_three_lines = lines_of("P", 3)
	var player_two_lines = lines_of("P", 2)
	var player_one_lines = lines_of("P", 1)
	var middle_empty_fields = middle_free_fields()
	var richard_three_lines = lines_of("R", 3)
	var richard_two_lines = lines_of("R", 2)
	var richard_one_lines = lines_of("R", 1)
	var potential_neighbor_plays = neighbors_with_points()
	# bonus cards
	var joker_lines = potential_three_lines_for_powermove([1])
	var switch_line = potential_option_for_switch_powermove()
	
	# check for richard bonus card plays
	if len(richard_bonus_cards) > 0:
		var next_bonus_card = richard_bonus_cards[len(richard_bonus_cards)-1]
		if next_bonus_card == "joker":
			if len(joker_lines) > 0 and joker_counter >= 0:
				delete_element_of_line(joker_lines[randi_range(0, len(joker_lines)-1)])
				richard_bonus_cards.pop_back()
				bonus_card_used = true
			elif len(player_three_lines) > 0 and joker_counter >= 1:
				delete_element_of_line(player_three_lines[randi_range(0, len(player_three_lines)-1)])
				richard_bonus_cards.pop_back()
				bonus_card_used = true
			elif len(player_two_lines) > 0 and joker_counter >= 2:
				delete_element_of_line(player_two_lines[randi_range(0, len(player_two_lines)-1)])
				richard_bonus_cards.pop_back()
				bonus_card_used = true
			elif joker_counter >= 3:
				delete_element_of_line(player_one_lines[randi_range(0, len(player_one_lines)-1)])
				richard_bonus_cards.pop_back()
				bonus_card_used = true
			else:
				joker_counter = joker_counter + 1
			if bonus_card_used:
				var color_options = ["yellow", "red", "green", "blue"]
				richard_hand_cards.append(color_options[randi_range(0, len(color_options)-1)])
		elif next_bonus_card == "switch":
			if len(switch_line) > 0 and switch_counter >= 0:
				switch_powermove(switch_line)
				richard_bonus_cards.pop_back()
				bonus_card_used = true
			elif switch_counter >= 2:
				switch_randomly()
				richard_bonus_cards.pop_back()
				bonus_card_used = true
			else:
				switch_counter = switch_counter + 1
		elif next_bonus_card == "doublepoints":
			play_doublepoint_field = true
			richard_bonus_cards.pop_back()
			bonus_card_used = true
		elif next_bonus_card == "lock":
			if len(player_two_lines) > 0:
				lock_line(player_two_lines[randi_range(0, len(player_two_lines)-1)])
				richard_bonus_cards.pop_back()
				bonus_card_used = true
			elif len(richard_two_lines) > 0:
				lock_line(richard_two_lines[randi_range(0, len(richard_two_lines)-1)])
				richard_bonus_cards.pop_back()
				bonus_card_used = true
	
	# prepare all relevant lines
	player_three_lines = lines_of("P", 3)
	player_two_lines = lines_of("P", 2)
	player_one_lines = lines_of("P", 1)
	middle_empty_fields = middle_free_fields()
	richard_three_lines = lines_of("R", 3)
	richard_two_lines = lines_of("R", 2)
	richard_one_lines = lines_of("R", 1)
	potential_neighbor_plays = neighbors_with_points()
	
	# prio without bonus cards
	select_play_pos_randomly() # else random
	if len(richard_one_lines) > 0: # check for possible line to build
		select_play_pos_for_line(richard_one_lines[randi_range(0, len(richard_one_lines)-1)])
	if len(potential_neighbor_plays) > 0: # check for neighbors
		select_play_pos_for_neighbors(potential_neighbor_plays)
	if len(richard_two_lines) > 0: # check for Lo2
		select_play_pos_for_line(richard_two_lines[randi_range(0, len(richard_two_lines)-1)])
	if len(richard_three_lines) > 0: # check for Lo3
		select_play_pos_for_line(richard_three_lines[randi_range(0, len(richard_three_lines)-1)])
	if len(middle_empty_fields) > 0: # check for middle
		select_play_pos_for_middle_fields(middle_empty_fields)
	if len(player_three_lines) > 0: # check for potential block (enemy Lo3)
		select_play_pos_for_line(player_three_lines[randi_range(0, len(player_three_lines)-1)])
	
	# Check for lock
	if position_first_pick == table_game.bonus_card_controller.confirmed_locked_field_position:
		if table_game.bonus_card_controller.locked_by == "Player":
			position_first_pick = position_second_pick
			color_first_pick = color_second_pick
	elif position_first_pick == table_game.bonus_card_controller.richard_confirmed_locked_field_position:
		if table_game.bonus_card_controller.locked_by2 != "Richard":
			position_first_pick = position_second_pick
			color_first_pick = color_second_pick
		else:
			# remove locked field
			table_game.gameboard_fields[position_first_pick].get_node("Locked").queue_free()
			table_game.bonus_card_controller.richard_confirmed_locked_field_position = -1
			table_game.bonus_card_controller.field_locked_by_richard = null
	
	
	# play doublepoint field if available
	if play_doublepoint_field:
		play_doublepoint(position_first_pick)
		play_doublepoint_field = false
	
	# update return values and richards hand
	if position_first_pick != -1:
		return_field = position_first_pick
	if color_first_pick != null:
		return_color = color_first_pick
	richard_hand_cards.erase(color_first_pick)
	
	return {"field": return_field, "color": return_color, "text": return_text}

####################################### API ZEUG ##################

#func _api_response(message, npc):
	#if npc == "Richard":
		# # Generate response
		#pass

####################################### SELECT POSITION AND LINES FOR POTENTIAL PLAY #############################################

func select_play_pos_randomly():
	var colors = ["yellow", "red", "green", "blue"]
	var free_field_positions = []
	for pos in range(16):
		if fields_played_by[pos] != "E":
			continue
		free_field_positions.append(pos)
	var play_color = colors[randi_range(0, len(colors)-1)]
	while play_color not in richard_hand_cards:
		play_color = colors[randi_range(0, len(colors)-1)]
	var play_position = free_field_positions[randi_range(0, len(free_field_positions)-1)]
	while play_position == table_game.bonus_card_controller.confirmed_locked_field_position:
		play_position = free_field_positions[randi_range(0, len(free_field_positions)-1)]
	if play_position != table_game.bonus_card_controller.confirmed_locked_field_position:
		safe_move(play_position, play_color)

# select the best option of playable neighbor points
func select_play_pos_for_neighbors(neighbors_dict):
	var colors = []
	var positions = []
	var points = []
	for entry in neighbors_dict:
		colors.append(entry["color"])
		positions.append(entry["position"])
		points.append(entry["points"])
	var highest_points = -1000
	var highest_points_at = -1
	for i in len(points):
		if points[i] > highest_points:
			if colors[i] in richard_hand_cards:
				highest_points = points[i]
				highest_points_at = i
	if positions[highest_points_at] != table_game.bonus_card_controller.confirmed_locked_field_position:
		safe_move(positions[highest_points_at], colors[highest_points_at])

# returns all positions that would give neighbor points when played
func neighbors_with_points():
	var return_neighbor_with_colors = []
	var free_field_positions = []
	for pos in range(16):
		if fields_played_by[pos] != "E":
			continue
		free_field_positions.append(pos)
	for pos in free_field_positions:
		var neighbors_of_pos = get_neighbor_positions(pos)
		for color in ["yellow", "red", "green", "blue"]:
			var points_for_play = 0
			for neighbor_pos in neighbors_of_pos:
				if fields_color[neighbor_pos] == color and fields_played_by[neighbor_pos] == "P":
					points_for_play = points_for_play + 1
				if fields_color[neighbor_pos] == color and fields_played_by[neighbor_pos] == "R":
					points_for_play = points_for_play - 1
			return_neighbor_with_colors.append({"color": color, "position": pos, "points": points_for_play})
	return return_neighbor_with_colors

func get_neighbor_positions(pos):
	var row = pos / 4
	var column = pos % 4
	var neighbors = []
	for horizontal in [-1, 0, 1]:
		for vertical in [-1, 0, 1]:
			if horizontal == 0 and vertical == 0:
				continue
			var current_row = row + horizontal
			var current_column = column + vertical
			if current_row >= 0 and current_row < 4 and current_column >= 0 and current_column < 4:
				var current_position = current_row * 4 + current_column
				neighbors.append(current_position)
	return neighbors

func select_play_pos_for_line(line):
	var colors_in_line = ["yellow", "red", "green", "blue"]
	for pos in line:
		if fields_color[pos] in colors_in_line:
			colors_in_line.erase(fields_color[pos])
	for pos in line:
		if fields_played_by[pos] == "E":
			var valid_colors = []
			for color in colors_in_line:
				if color in richard_hand_cards:
					valid_colors.append(color)
			var play_color = null
			if len(valid_colors) > 0:
				play_color = valid_colors[randi_range(0, len(valid_colors)-1)]
			else:
				play_color = richard_hand_cards[randi_range(0, len(richard_hand_cards)-1)]
			if pos != table_game.bonus_card_controller.confirmed_locked_field_position:
				safe_move(pos, play_color)

func safe_move(new_position, new_color):
	if (position_first_pick == -1 and color_first_pick != null) or (position_first_pick != -1 and color_first_pick == null) or (position_second_pick == -1 and color_second_pick != null) or (position_second_pick != -1 and color_second_pick == null):
		printerr("Invalid pairing during safe_move noticed!")
	if position_first_pick == -1 and color_first_pick == null:
		position_first_pick = new_position
		color_first_pick = new_color
	else:
		position_second_pick = position_first_pick
		color_second_pick = color_first_pick
		position_first_pick = new_position
		color_first_pick = new_color

func middle_free_fields():
	var free_middle_fields = []
	for pos in [5,6,9,10]:
		if fields_played_by[pos] == "E":
			free_middle_fields.append(pos)
	return free_middle_fields

func select_play_pos_for_middle_fields(middle_empty_fields):
	var color_options = ["yellow", "red", "green", "blue"]
	var new_pos = middle_empty_fields[randi_range(0, len(middle_empty_fields)-1)]
	var valid_colors = []
	for color in color_options:
		if color in richard_hand_cards:
			valid_colors.append(color)
	var play_color = null
	if len(valid_colors) > 0:
		play_color = valid_colors[randi_range(0, len(valid_colors)-1)]
	else:
		play_color = richard_hand_cards[randi_range(0, len(richard_hand_cards)-1)]
	if new_pos != table_game.bonus_card_controller.confirmed_locked_field_position:
		safe_move(new_pos, play_color)

############################################ LINES OF #########################################################

func lines_of(played_by_letter, line_length):
	var return_lines_of = []
	return_lines_of.append_array(rows_of(played_by_letter, line_length))
	return_lines_of.append_array(columns_of(played_by_letter, line_length))
	return_lines_of.append_array(diagonals_of(played_by_letter, line_length))
	var return_lines_of_iterate = return_lines_of.duplicate()
	for line in return_lines_of_iterate:
		for pos in line:
			if fields_played_by[pos] != played_by_letter and fields_played_by[pos] != "E":
				return_lines_of.erase(line)
	return return_lines_of

func rows_of(played_by_letter, line_length):
	var return_line_of_threes = []
	var current_array_of_four = ["-", "-", "-", "-"]
	for row in range(4):
		current_array_of_four = [fields_played_by[row*4+0], fields_played_by[row*4+1], fields_played_by[row*4+2], fields_played_by[row*4+3]]
		if current_array_of_four.count(played_by_letter) == line_length:
			return_line_of_threes.append([row*4+0, row*4+1, row*4+2, row*4+3])
	return return_line_of_threes

func columns_of(played_by_letter, line_length):
	var return_line_of_threes = []
	var current_array_of_four = ["-", "-", "-", "-"]
	for column in range(4):
		current_array_of_four = [fields_played_by[0*4+column], fields_played_by[1*4+column], fields_played_by[2*4+column], fields_played_by[3*4+column]]
		if current_array_of_four.count(played_by_letter) == line_length:
			return_line_of_threes.append([0*4+column, 1*4+column, 2*4+column, 3*4+column])
	return return_line_of_threes

func diagonals_of(played_by_letter, line_length):
	var return_line_of_threes = []
	var current_array_of_four_one = ["-", "-", "-", "-"]
	var current_array_of_four_two = ["-", "-", "-", "-"]
	current_array_of_four_one = [fields_played_by[0], fields_played_by[5], fields_played_by[10], fields_played_by[15]]
	current_array_of_four_two = [fields_played_by[3], fields_played_by[6], fields_played_by[9], fields_played_by[12]]
	if current_array_of_four_one.count(played_by_letter) == line_length:
		return_line_of_threes.append([0,5,10,15])
	if current_array_of_four_two.count(played_by_letter) == line_length:
		return_line_of_threes.append([3,6,9,12])
	return return_line_of_threes

############################################ BONUS CARDS #########################################################

func delete_element_of_line(player_line):
	var possible_deletion = []
	for pos in player_line:
		if fields_played_by[pos] == "P":
			possible_deletion.append(pos)
	var deletion = possible_deletion[randi_range(0, len(possible_deletion)-1)]
	var row = deletion / 4 + 1
	var column = deletion % 4 + 1
	table_game.bonus_card_controller.currently_playing("Richard")
	table_game.bonus_card_controller.delete(table_game.gameboard_fields[deletion])
	bonus_card_label.text = str("Richard used Joker on (", row, ", ", column, ")")

func potential_three_lines_for_powermove(array_with_amount_of_player_cards_allowed):
	var return_lines = []
	return_lines.append_array(rows_of("R", 2))
	return_lines.append_array(columns_of("R", 2))
	return_lines.append_array(diagonals_of("R", 2))
	var return_lines_iterate = return_lines.duplicate()
	for line in return_lines_iterate:
		var count_player_cards = 0
		for pos in line:
			if fields_played_by[pos] == "P":
				count_player_cards = count_player_cards + 1
		if !array_with_amount_of_player_cards_allowed.has(count_player_cards):
			return_lines.erase(line)
	return return_lines

func potential_option_for_switch_powermove():
	var powermove_lines = potential_three_lines_for_powermove([0,1])
	for line in powermove_lines:
		var color_options = ["yellow", "red", "green", "blue"]
		for pos in line:
			color_options.erase(fields_color[pos])
		for i in range(16):
			if fields_played_by[i] == "R" and fields_color[i] in color_options:
				switch_field_position_needed_for_powermove = i
				return line
	return []

func switch_powermove(powermove_line):
	var count_player_cards = 0
	for pos in powermove_line:
		if fields_played_by[pos] == "P":
			count_player_cards = count_player_cards + 1
	var pos_to_swap_on_line = -1
	if count_player_cards == 1:
		for pos in powermove_line:
			if fields_played_by[pos] == "P":
				pos_to_swap_on_line = pos
	elif count_player_cards == 0:
		for pos in powermove_line:
			if fields_played_by[pos] == "E":
				pos_to_swap_on_line = pos
	else:
		printerr("powerline in switch_powermove has 2 or more player cards")
	
	table_game.bonus_card_controller.currently_playing("Richard")
	table_game.bonus_card_controller.switch_fields(table_game.gameboard_fields[pos_to_swap_on_line], table_game.gameboard_fields[switch_field_position_needed_for_powermove])
	table_game.point_system_controller.calculate_points(table_game.gameboard_fields.find(table_game.gameboard_fields[pos_to_swap_on_line]), "Richard")
	table_game.point_system_controller.calculate_points(table_game.gameboard_fields.find(table_game.gameboard_fields[switch_field_position_needed_for_powermove]), "Richard")
	var row1 = pos_to_swap_on_line / 4 + 1
	var column1 = pos_to_swap_on_line % 4 + 1
	var row2 = switch_field_position_needed_for_powermove / 4 + 1
	var column2 = switch_field_position_needed_for_powermove % 4 + 1
	bonus_card_label.text = str("Richard used Switch on\n(", row1, ", ", column1, ") and (", row2, ", ", column2, ")")

func switch_randomly():
	var pos_to_swap_on_line = randi_range(0, 15)
	var array = range(16)
	array.erase(pos_to_swap_on_line)
	switch_field_position_needed_for_powermove = array[randi_range(0, len(array)-1)]
	table_game.bonus_card_controller.currently_playing("Richard")
	table_game.bonus_card_controller.switch_fields(table_game.gameboard_fields[pos_to_swap_on_line], table_game.gameboard_fields[switch_field_position_needed_for_powermove])
	table_game.point_system_controller.calculate_points(table_game.gameboard_fields.find(table_game.gameboard_fields[pos_to_swap_on_line]), "Richard")
	table_game.point_system_controller.calculate_points(table_game.gameboard_fields.find(table_game.gameboard_fields[switch_field_position_needed_for_powermove]), "Richard")
	var row1 = pos_to_swap_on_line / 4 + 1
	var column1 = pos_to_swap_on_line % 4 + 1
	var row2 = switch_field_position_needed_for_powermove / 4 + 1
	var column2 = switch_field_position_needed_for_powermove % 4 + 1
	bonus_card_label.text = str("Richard used Switch on\n(", row1, ", ", column1, ") and (", row2, ", ", column2, ")")

func play_doublepoint(pos):
	table_game.bonus_card_controller.currently_playing("Richard")
	table_game.bonus_card_controller.create_doublepoints_field(table_game.gameboard_fields[pos])
	var row = pos / 4 + 1
	var column = pos % 4 + 1
	bonus_card_label.text = str("Richard used DoublePoints\non (", row, ", ", column, ")")

func lock_line(line_to_lock):
	for pos in line_to_lock:
		if fields_played_by[pos] == "E":
			table_game.bonus_card_controller.currently_playing("Richard")
			table_game.bonus_card_controller.field_locked_by_richard = table_game.gameboard_fields[pos]
			table_game.bonus_card_controller.richard_execute_lock()
			var row = pos / 4 + 1
			var column = pos % 4 + 1
			bonus_card_label.text = str("Richard used Lock\non (", row, ", ", column, ")")
			return

#################################################################################################################################
