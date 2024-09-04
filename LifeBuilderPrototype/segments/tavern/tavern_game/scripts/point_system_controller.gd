extends Control

@onready var table_game = $".."

var gamefield = []
var gamefield_colors = []
var played_by_player = []
var played_by_richard = []

func _ready():
	initiate_variables()
	update_gamefield()

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
		gamefield_colors[i] = field_border_color
		if field_border_color == table_game.player_color:
			played_by_player[i] = true
		elif field_border_color == table_game.richard_color:
			played_by_richard[i] = true

func preview_move(card_position, card_color, card_player):
	pass

func calculate_points(card_position, _card_color, card_player):
	
	update_gamefield()
	if !gamefield[card_position]:
		return
	
	var own_total_points = 0
	var enemy_total_points = 0
	
	var current_played_by = null
	var current_played_against = null
	if card_player == "Player":
		current_played_by = played_by_player
		current_played_against = played_by_richard
	elif card_player == "Richard":
		current_played_by = played_by_richard
		current_played_against = played_by_player
	else:
		printerr("card_player not allowed!")
	
	var neighbors = get_neighbors(card_position)
	for neighbor in neighbors:
		var own_card_color = gamefield[card_position].get_node("Card").get_theme_stylebox("panel").bg_color
		var neighbor_card_color = neighbor["field"].get_node("Card").get_theme_stylebox("panel").bg_color
		if neighbor_card_color == own_card_color and current_played_by[neighbor["position"]] == true:				# played card is next to own card of same color
			enemy_total_points = enemy_total_points + 1
			print("Next to own card")
		if neighbor_card_color == own_card_color and current_played_against[neighbor["position"]] == true:			# played card is next to enemy card of same color
			own_total_points = own_total_points + 1
			print("Next to enemy card")
	
	var row = card_position / 4
	var column = card_position % 4
	
	# row
	var row_colors = []
	for current_column in range(4):
		var current_position = row * 4 + current_column
		if current_played_by[current_position] != true:
			break
		row_colors.append(gamefield[current_position].get_node("Card").get_theme_stylebox("panel").bg_color)
	if len(row_colors) == 4:
		if array_has_duplicates(row_colors):
			own_total_points = own_total_points + 2
			print("Row of 4")
		else:
			own_total_points = own_total_points + 3
			print("Rainbow Row of 4")
	
	# column
	var column_colors = []
	for current_row in range(4):
		var current_position = current_row * 4 + column
		if current_played_by[current_position] != true:
			break
		column_colors.append(gamefield[current_position].get_node("Card").get_theme_stylebox("panel").bg_color)
	if len(column_colors) == 4:
		if array_has_duplicates(column_colors):
			own_total_points = own_total_points + 2
			print("Column of 4")
		else:
			own_total_points = own_total_points + 3
			print("Rainbow Column of 4")
	
	## rows
	#for row in range(4):
		#var row_colors = []
		#for current_column in range(4):
			#var current_position = row * 4 + current_column
			#if current_played_by[current_position] != true:
				#break
			#row_colors.append(gamefield[current_position].get_node("Card").get_theme_stylebox("panel").bg_color)
		#if len(row_colors) == 4:
			#if array_has_duplicates(row_colors):
				#own_total_points = own_total_points + 2
				#print("Row of 4")
			#else:
				#own_total_points = own_total_points + 3
				#print("Rainbow Row of 4")
	
	## columns
	#for column in range(4):
		#var column_colors = []
		#for current_row in range(4):
			#var current_position = current_row * 4 + column
			#if current_played_by[current_position] != true:
				#break
			#column_colors.append(gamefield[current_position].get_node("Card").get_theme_stylebox("panel").bg_color)
		#if len(column_colors) == 4:
			#if array_has_duplicates(column_colors):
				#own_total_points = own_total_points + 2
				#print("Column of 4")
			#else:
				#own_total_points = own_total_points + 3
				#print("Rainbow Column of 4")
	
	# diagonals
	if card_position in range(0,16,5):
		var diagonal_colors = []
		for current_position in range(0,16,5):
			print(current_played_against[current_position])
			if current_played_against[current_position] == true:
				break
			var current_card_color = gamefield[current_position].get_node("Card").get_theme_stylebox("panel").bg_color
			print(current_position, ": ", current_card_color)
			if current_card_color == table_game.player_color or current_card_color == table_game.richard_color:
				diagonal_colors.append(gamefield[current_position].get_node("Card").get_theme_stylebox("panel").bg_color)
			if len(diagonal_colors) == 4:
				if array_has_duplicates(diagonal_colors):
					own_total_points = own_total_points + 2
					print("Diagonal of 4")
				else:
					own_total_points = own_total_points + 3
					print("Rainbow Diagonal of 4")
	
	if card_position in range(3,13,3):
		var diagonal_colors = []
		for current_position in range(3,13,3):
			if current_played_against[current_position] == true:
				break
			var current_card_border_color = gamefield[current_position].get_node("Card").get_theme_stylebox("panel").border_color
			print(current_position, ": ", current_card_border_color)
			if current_card_border_color == table_game.player_color or current_card_border_color == table_game.richard_color:
				diagonal_colors.append(gamefield[current_position].get_node("Card").get_theme_stylebox("panel").bg_color)
			if len(diagonal_colors) == 4:
				if array_has_duplicates(diagonal_colors):
					own_total_points = own_total_points + 2
					print("Diagonal of 4")
				else:
					own_total_points = own_total_points + 3
					print("Rainbow Diagonal of 4")
	
	print("Own points: ", own_total_points, " - Enemy points: ", enemy_total_points)

func array_has_duplicates(array):
	for element in array:
		var counter = 0
		for i in array:
			if element == i:
				counter = counter + 1
		if counter > 1:
			return true
	return false

func get_neighbors(field_position):
	var neighbors = []
	var row = field_position / 4
	var column = field_position % 4
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
