extends Control

@onready var table_game = $".."
@onready var richard = $"../Richard"

var gamefield = []
var gamefield_colors = []
var played_by_player = []
var played_by_richard = []

# for calculation
var own_total_points
var enemy_total_points
var current_played_by
var current_played_against 
var row
var column

# bonus cards
var doublepoints_field_positions = []

func _ready():
	initiate_variables()
	update_gamefield()
	richard.connect("game_finished", func(): end_game())

func initiate_variables():
	gamefield_colors.resize(16)
	gamefield_colors.fill(null)
	played_by_player.resize(16)
	played_by_player.fill(false)
	played_by_richard.resize(16)
	played_by_richard.fill(false)

func update_gamefield():
	gamefield = table_game.gameboard_fields
	for i in range(len(gamefield)):
		var field = gamefield[i]
		var field_border_color = field.get_node("Card").get_theme_stylebox("panel").border_color
		var field_bg_color = field.get_node("Card").get_theme_stylebox("panel").bg_color
		gamefield_colors[i] = field_bg_color
		if field_border_color == table_game.player_color:
			played_by_player[i] = true
			played_by_richard[i] = false
		elif field_border_color == table_game.richard_color:
			played_by_richard[i] = true
			played_by_player[i] = false
		else:
			played_by_richard[i] = false
			played_by_player[i] = false

#################################### PREVIEW POINTS ################################################

func preview_move(field):
	for element in table_game.gameboard_fields:
		element.get_node("PreviewPoints").text = ""
	if field in table_game.gameboard_fields:
		var temp = return_calculate_points(table_game.gameboard_fields.find(table_game.last_selected_field))
		field.get_node("PreviewPoints").text = str(temp)

func return_calculate_points(card_position):
	
	update_gamefield()
	if !gamefield[card_position]:
		return
	
	var gamefield_old = gamefield
	var gamefield_new = []
	for element_old in gamefield_old:
		var element_new = element_old.duplicate()
		gamefield_new.append(element_new)
	gamefield = gamefield_new
	gamefield[card_position].get_node("Card").add_theme_stylebox_override("panel", gamefield[card_position].get_node("Card").get_theme_stylebox("panel").duplicate())
	gamefield[card_position].get_node("Card").get_theme_stylebox("panel").bg_color = table_game.currently_shown_edit_card.get_theme_stylebox("panel").bg_color
	gamefield[card_position].get_node("Card").get_theme_stylebox("panel").border_color = table_game.player_color
	gamefield[card_position].get_node("Card").add_to_group("FieldCard")
	gamefield_colors[card_position] = gamefield[card_position].get_node("Card").get_theme_stylebox("panel").bg_color
	played_by_player[card_position] = true
	played_by_richard[card_position] = false
	
	# reset variables for calculation
	own_total_points = 0
	enemy_total_points = 0
	current_played_by = null
	current_played_against = null
	row = card_position / 4
	column = card_position % 4

	current_played_by = played_by_player
	current_played_against = played_by_richard
	
	# update gamefield points
	check_neighbors()
	check_row()
	check_column()
	check_diagonal()
	
	return own_total_points - enemy_total_points

#################################### CALCULATE POINTS ################################################

func calculate_points(card_position, card_player):
	
	update_gamefield()
	if !gamefield[card_position]:
		return
	
	# reset variables for calculation
	own_total_points = 0
	enemy_total_points = 0
	current_played_by = null
	current_played_against = null
	row = card_position / 4
	column = card_position % 4
	
	# check which player is active
	if card_player == "Player":
		current_played_by = played_by_player
		current_played_against = played_by_richard
	elif card_player == "Richard":
		current_played_by = played_by_richard
		current_played_against = played_by_player
	else:
		printerr("Invalid Input for \"card_player\"!")
	
	# update gamefield points
	check_neighbors()
	check_row()
	check_column()
	check_diagonal()
	
	# save points
	if card_player == "Player":
		table_game.player_points = table_game.player_points + own_total_points
		table_game.richard_points = table_game.richard_points + enemy_total_points
	if card_player == "Richard":
		table_game.richard_points = table_game.richard_points + own_total_points
		table_game.player_points = table_game.player_points + enemy_total_points
	
	# set points on labels
	get_node("PlayerPointsPanel").get_node("PlayerPoints").text = str(table_game.player_points)
	get_node("RichardPointsPanel").get_node("RichardPoints").text = str(table_game.richard_points)

#################################### CHECK PARTS ################################################

func check_row():
	var row_positions = []
	var row_colors = []
	for current_column in range(4):
		var current_position = row * 4 + current_column
		if current_played_by[current_position] != true:
			break
		row_colors.append(gamefield[current_position].get_node("Card").get_theme_stylebox("panel").bg_color)
		row_positions.append(current_position)
	
	var multiplier = 1
	if len(row_colors) == 4:
		for element in row_positions:
			for doublepoints_field_position in doublepoints_field_positions:
				if element == doublepoints_field_position:
					multiplier = multiplier * 2
		if array_has_duplicates(row_colors):
			own_total_points = own_total_points + 2 * multiplier
		else:
			own_total_points = own_total_points + 3 * multiplier

func check_column():
	var column_positions = []
	var column_colors = []
	for current_row in range(4):
		var current_position = current_row * 4 + column
		if current_played_by[current_position] != true:
			break
		column_colors.append(gamefield[current_position].get_node("Card").get_theme_stylebox("panel").bg_color)
		column_positions.append(current_position)
	
	var multiplier = 1
	if len(column_colors) == 4:
		for element in column_positions:
			for doublepoints_field_position in doublepoints_field_positions:
				if element == doublepoints_field_position:
					multiplier = multiplier * 2
		if array_has_duplicates(column_colors):
			own_total_points = own_total_points + 2 * multiplier
		else:
			own_total_points = own_total_points + 3 * multiplier

func check_neighbors():
	var card_position = row * 4 + column
	var neighbors = get_neighbors()
	for neighbor in neighbors:
		var own_card_color = gamefield[card_position].get_node("Card").get_theme_stylebox("panel").bg_color
		var neighbor_card_color = neighbor["field"].get_node("Card").get_theme_stylebox("panel").bg_color
		var multiplier = 1
		if neighbor_card_color == own_card_color and current_played_by[neighbor["position"]] == true:				# played card is next to own card of same color
			if card_position in doublepoints_field_positions:
				for doublepoints_field_position in doublepoints_field_positions:
					if card_position == doublepoints_field_position:
						multiplier = multiplier * 2
			if neighbor["position"] in doublepoints_field_positions:
				for doublepoints_field_position in doublepoints_field_positions:
					if neighbor["position"] == doublepoints_field_position:
						multiplier = multiplier * 2
			enemy_total_points = enemy_total_points + 1 * multiplier
		multiplier = 1
		if neighbor_card_color == own_card_color and current_played_against[neighbor["position"]] == true:			# played card is next to enemy card of same color
			if card_position in doublepoints_field_positions:
				for doublepoints_field_position in doublepoints_field_positions:
					if card_position == doublepoints_field_position:
						multiplier = multiplier * 2
			if neighbor["position"] in doublepoints_field_positions:
				for doublepoints_field_position in doublepoints_field_positions:
					if neighbor["position"] == doublepoints_field_position:
						multiplier = multiplier * 2
			own_total_points = own_total_points + 1 * multiplier

func check_diagonal():
	
	var field = row * 4 + column
	var diagonal_fields = []
	if field in range(0,16,5):
		diagonal_fields = range(0,16,5)
	elif field in range(3,13,3):
		diagonal_fields = range(3,13,3)
	else:
		return false
	
	var diagonal_positions = []
	var diagonal_colors = []
	for current_position in diagonal_fields:
		if current_played_against[current_position] == true:
			break
		var current_card_border_color = gamefield[current_position].get_node("Card").get_theme_stylebox("panel").border_color
		if current_card_border_color == table_game.player_color or current_card_border_color == table_game.richard_color:
			diagonal_colors.append(gamefield[current_position].get_node("Card").get_theme_stylebox("panel").bg_color)
			diagonal_positions.append(current_position)
	
		var multiplier = 1
		if len(diagonal_colors) == 4:
			for element in diagonal_positions:
				for doublepoints_field_position in doublepoints_field_positions:
					if element == doublepoints_field_position:
						multiplier = multiplier * 2
			if array_has_duplicates(diagonal_colors):
				own_total_points = own_total_points + 2 * multiplier
			else:
				own_total_points = own_total_points + 3 * multiplier

func array_has_duplicates(array):
	for element in array:
		var counter = 0
		for i in array:
			if element == i:
				counter = counter + 1
		if counter > 1:
			return true
	return false

func get_neighbors():
	var neighbors = []
	for horizontal in [-1, 0, 1]:
		for vertical in [-1, 0, 1]:
			if horizontal == 0 and vertical == 0:
				continue
			var current_row = row + horizontal
			var current_column = column + vertical
			if current_row >= 0 and current_row < 4 and current_column >= 0 and current_column < 4:
				var current_position = current_row * 4 + current_column
				neighbors.append({"position": current_position, "field": gamefield[current_position]})
	return neighbors

func end_game():
	table_game.get_node("ScoreBoard").visible = true
	table_game.get_node("ScoreBoard").get_node("PlayerPointsLabel").text = str(table_game.player_points)
	table_game.get_node("ScoreBoard").get_node("RichardPointsLabel").text = str(table_game.richard_points)
	var text = ""
	if table_game.player_points > table_game.richard_points:
		text = "Player won!"
	elif table_game.player_points < table_game.richard_points:
		text = "Richard won!"
	else:
		text = "Draw!"
	table_game.get_node("ScoreBoard").get_node("WonLabel").text = text
