extends Node

############################################ VARIABLES #########################################################

signal player_played_card()

@onready var highlighting_controller = $GameBoard/HighlightController	# Handles all highlighting
@onready var point_system_controller = $PointSystemController			# Handles all point calculation
@onready var bonus_card_controller = $BonusCardController				# Handles all bonus cards
@onready var player_deck = $"../TableGame/Deck"							# Bonus-card deck
@onready var player_hand_cards = $"../TableGame/PlayerCards"			# Players hand cards
@onready var field_cards_preview = $"../TableGame/BigCardsOnField"		# Preview cards (left)
@onready var player_edit_cards = $"../TableGame/EditCards"				# Edit cards (right)
@onready var play_card_button = $GameBoard/PlayCardButton				# Button to play card
@onready var play_reflect_card_button = $ReflectionCardField/Button		# Button to play reflect card
@onready var draw_card_button											# Button to draw bonus-card

# Static card data
var style_boxes

# All card colors
var colors = {Color("#ea4d53"): "red",
			  Color("#ebbc6d"): "yellow",
			  Color("#328948"): "green",
			  Color("#554dc9"): "blue",
			  Color("#989595"): "grey",
			  Color("#7fffd4"): "aquamarine"}
var player_color = Color("#000000")
var richard_color = Color("#FFFFFF")

# Card texts (grey bonus cards get text based on effect)
var card_types = {"red":    "EMOTIONEN\nWie fühlst du dich in Bezug auf das zu reflektierende Thema? Welche positiven oder negativen Gefühle empfindest du?\n[ Fang an zu tippen.. ]",
				  "yellow": "FAKTEN\nWelche für deine Reflektion relevanten Fakten, Daten, Informationen fallen dir ein?\n[ Fang an zu tippen.. ]",
				  "green":  "OPTIMISMUS\nWelche Vorteile oder Möglichkeiten ergeben sich?\n[ Fang an zu tippen.. ]",
				  "blue":   "KREATIVITÄT\nWelche verrückten oder eher fernen Dinge fallen die zu deinem Thema ein?\n[ Fang an zu tippen.. ]",
				  "aquamarine": "REFLEKTION\nWorüber möchtest du diese Runde reflektieren? Schreibe dein Thema auf.\n[ Fang an zu tippen.. ]"}

# Card icons (grey bonus cards get icons based on effect, aquamarine does not need an icon)
var card_icons = {"red":    "res://ressources/icons/face.svg",
				  "yellow": "res://ressources/icons/note.svg",
				  "green":  "res://ressources/icons/thumb.svg",
				  "blue":   "res://ressources/icons/bulb.svg"}

# Bonus card effect text
var bonus_card_effects = {"joker": "Entferne eine gegnerische Karte aus dem Spiel und bekomme eine beliebige Perspektivenkarte auf die Hand.",
						  "switch": "Wähle eine Karte und tausche die Position mit einem nicht gelockten Feld (andere Karte oder leeres Feld).", 
						  "doublepoints": "Spiele diese Karte auf ein Feld. Alle mit diesem Feld verdienten Punkte werden verdoppelt.",
						  "lock":  "Reserviere ein leeres Feld für dich, der Gegner kann darauf keine Karte spielen.\n\nODER\n\nSperre eine Karte. Gesperrte Karten können nicht entfernt oder bewegt werden."}

# Bonus card icons
var bonus_card_icons = {"joker": "res://ressources/icons/joker.svg",
						 "switch": "res://ressources/icons/switch.svg", 
						 "doublepoints": "res://ressources/icons/doublepoints.png",
						 "lock": "res://ressources/icons/lock.svg"}

# information for game
var gameboard_fields : Array
var field_is_selected : bool = false
var selected_field : ReferenceRect = null
var active_card : Panel = null
var player_bonus_card_effects : Array
var edit_to_hand_cards : Dictionary = {}
var field_to_preview_cards : Dictionary = {}
var bonus_cards : Dictionary = {}
var reflection_card_filled : bool = false
var reflect_field_is_selected : bool = false

# bonus card variables
var switch_ongoing : bool = false
var joker_ongoing : bool = false
var doublepoints_ongoing : bool = false
var lock_ongoing : bool = false
var player_played_bonus_card : bool = false

# points
var player_points : int = 0
var richard_points : int = 0

############################################ PROCESS #########################################################

func _process(_delta):
	
	if !reflection_card_filled and reflect_field_is_selected:
		if active_card != null:
			play_card_button.visible = true
		else:
			play_card_button.visible = false
	
	# Update visibility of play button
	if reflection_card_filled and !switch_ongoing and !joker_ongoing and !doublepoints_ongoing and !lock_ongoing:
		if field_is_selected and active_card != null:
			play_card_button.visible = true
		else:
			play_card_button.visible = false
	
	# Update text for hand cards according to edit
	for edit_card in edit_to_hand_cards.keys():
		var edit_card_text = edit_card.get_child(0).text
		if len(edit_card_text) == 0:
			edit_to_hand_cards[edit_card].get_child(1).visible = true
			edit_to_hand_cards[edit_card].get_child(0).text = ""
		else:
			edit_to_hand_cards[edit_card].get_child(1).visible = false
			edit_to_hand_cards[edit_card].get_child(0).text = edit_card_text

############################################ INITIATION #########################################################

# Loaded when entering tavern
func _ready():
	initiate_gameboard()

# Prepare game without player cards, after filling reflection card initiate player cards
func initiate_gameboard():
	if !reflection_card_filled:
		initiate_style_boxes()
		initiate_field_buttons()
		initiate_reflection_card()
	else:
		initiate_player_cards()
		initiate_player_deck()
		bonus_card_controller.initiate_draw_widget()
		get_node("PointSystemController").visible = true

# Prepare style boxes for cards
func initiate_style_boxes():
	style_boxes = {}
	for color in colors.keys():
		var new_style_box = StyleBoxFlat.new()
		new_style_box.bg_color = color
		new_style_box.border_width_left = 1
		new_style_box.border_width_top = 1
		new_style_box.border_width_right = 1
		new_style_box.border_width_bottom = 1
		new_style_box.border_color = Color("#000000")
		style_boxes[colors[color]] = new_style_box

############################################ FIELD #########################################################

# Prepare fields with buttons
func initiate_field_buttons():
	update_fields()
	for field in gameboard_fields:
		field.find_child("Card").size_flags_horizontal = Control.SIZE_SHRINK_CENTER | Control.SIZE_EXPAND
		var field_button = field.find_child("Button")
		field_button.connect("focus_entered", func(): _field_selected(field_button))
		field_button.connect("focus_exited", func(): _field_deselected())
		field_button.connect("mouse_entered", func(): _hovering_over_button(field_button))
		field_button.connect("mouse_exited", func(): _stop_hovering_over_button(field_button))
	play_card_button.connect("button_down", func(): _play_card_button_pressed())
	play_reflect_card_button.connect("button_down", func(): _play_reflect_card(play_reflect_card_button))

func update_fields():
	gameboard_fields = self.find_child("GameBoard").find_child("MarginContainer").find_child("PanelContainer").find_child("Fields").get_children()
	field_is_selected = false
	selected_field = null
	active_card = null

func _field_selected(button):
	
	if !reflection_card_filled:
		reflect_field_is_selected = false
		play_card_button.visible = false
	
	var field = button.get_parent()
	
	if switch_ongoing:
		bonus_card_controller.switch_field(field)
		return
	
	if joker_ongoing:
		bonus_card_controller.joker_field(field)
		return
	
	if doublepoints_ongoing:
		bonus_card_controller.doublepoints_field(field)
		return
	
	if lock_ongoing:
		bonus_card_controller.lock_field(field)
		return
	
	field_is_selected = true
	selected_field = field

func _field_deselected():
	pass#field_is_selected = false

func _hovering_over_button(button):
	var field_card = find_field_card(button.get_parent())
	if field_card:
		field_to_preview_cards[field_card].visible = true

func _stop_hovering_over_button(button):
	var field_card = find_field_card(button.get_parent())
	if field_card:
		field_to_preview_cards[field_card].visible = false

func find_field_card(field):
	var card = field.get_node("Card")
	if card.get_groups().has("FieldCard"):
		return card
	return null

func find_field_button(field):
	var button = field.find_child("Button")
	if button.get_groups().has("FieldButton"):
		return button
	return null

# Prepare reflection card
func initiate_reflection_card():
	var reflection_card_edit = create_edit_card(colors[colors.keys()[5]])
	reflection_card_edit.visible = true
	active_card = reflection_card_edit
	highlighting_controller.highlight_no_fields()
	highlighting_controller.highlight_reflect_field_on()

func _play_reflect_card(button):
	var field = button.get_parent()
	reflect_field_is_selected = true
	selected_field = field

############################################ PLAYER #########################################################

# Prepare player hand cards
func initiate_player_cards():
	for color in ["red", "yellow", "green", "blue"]:
		create_hand_card(color, card_icons[color])
		create_hand_card(color, card_icons[color])

# Prepare player bonus card deck
func initiate_player_deck():
	player_bonus_card_effects = generate_random_effects()
	for i in range(3):
		var next_card = create_small_card("grey", "Icon", bonus_card_icons[player_bonus_card_effects[i]], bonus_card_effects[player_bonus_card_effects[i]])
		next_card.position = Vector2(0 + 2*i, 0 - 2*i)
		player_deck.add_child(next_card)
		var next_card_big = create_big_card("grey", "Preview", bonus_card_effects[player_bonus_card_effects[i]])
		player_edit_cards.add_child(next_card_big)
		bonus_cards[player_bonus_card_effects[i]] = next_card_big
	var new_draw_button = Button.new()
	new_draw_button.size = Vector2(39, 39)
	new_draw_button.position = Vector2(0, -4)
	new_draw_button.flat = true
	player_deck.add_child(new_draw_button)
	draw_card_button = new_draw_button
	draw_card_button.connect("button_down", func(): _draw_button_pressed(draw_card_button))
	draw_card_button.connect("button_up", func(): _draw_button_released(draw_card_button))

func generate_random_effects():
	var random_effects = ["switch", "doublepoints", "lock"]
	random_effects.shuffle()
	random_effects = random_effects.slice(0,2)
	random_effects.append("joker")
	random_effects.shuffle()
	return random_effects

func _draw_button_pressed(button):
	button.grab_focus()

func _draw_button_released(button):
	button.release_focus()
	_show_next_bonus_card()

func _show_next_bonus_card():
	
	if player_played_bonus_card:
		return
	
	if len(bonus_cards) < 1:
		return
	
	update_edit_cards(bonus_cards.values()[len(bonus_cards)-1])
	
	# Check what bonus card is being pressed
	if bonus_cards.keys()[len(bonus_cards)-1] == "switch":
		if switch_ongoing:
			bonus_card_controller.cancel_switch()
		else:
			bonus_card_controller.start_switch()
	elif bonus_cards.keys()[len(bonus_cards)-1] == "joker":
		if joker_ongoing:
			bonus_card_controller.cancel_joker()
		else:
			bonus_card_controller.start_joker()
	elif bonus_cards.keys()[len(bonus_cards)-1] == "doublepoints":
		if doublepoints_ongoing:
			bonus_card_controller.cancel_doublepoints()
		else:
			bonus_card_controller.start_doublepoints()
	elif bonus_cards.keys()[len(bonus_cards)-1] == "lock":
		if lock_ongoing:
			bonus_card_controller.cancel_lock()
		else:
			bonus_card_controller.start_lock()

func _click_hand_card(edit_card):
	
	if !reflection_card_filled:
		return
	
	if switch_ongoing:
		bonus_card_controller.cancel_switch()
	
	if joker_ongoing:
		bonus_card_controller.cancel_joker()
	
	if doublepoints_ongoing:
		bonus_card_controller.cancel_doublepoints()
	
	if lock_ongoing:
		bonus_card_controller.cancel_lock()
	
	update_edit_cards(edit_card)

func update_edit_cards(edit_card):
	for card in player_edit_cards.get_children():
		if card == edit_card:
			edit_card.visible = !edit_card.visible
			if edit_card.visible:
				active_card = edit_card
				highlighting_controller.highlight_empty_fields()
			else:
				active_card = null
				highlighting_controller.highlight_no_fields()
		else:
			card.visible = false

############################################ PLAYING CARD #########################################################

# PlayButton pressed
func _play_card_button_pressed():
	
	# play reflection card if not played yet
	if !reflection_card_filled:
		play_reflect_card()
		return
	
	if play_card_on_field_allowed(selected_field):
		if colors[active_card.get_theme_stylebox("panel").bg_color] != "grey":
			play_card()
	else:
		print("This move is not allowed!")

func play_card_on_field_allowed(field):
	if colors[active_card.get_theme_stylebox("panel").bg_color] == "grey":
		if bonus_card_controller.confirm_bonus_card_play():
			bonus_card_controller.currently_playing("Player")
			bonus_card_controller.execute_bonus_card()
			return true
	else:
		if find_field_card(field):
			return false
		else:
			return true

# Card played
func play_card():
	
	# check if card text is empty
	if len(active_card.get_child(0).text) == 0:
		print("Please type something on the card!")
		return
	
	var field_position = gameboard_fields.find(selected_field)
	var color_name = colors[active_card.get_theme_stylebox("panel").bg_color]
	
	# Check for lock
	if field_position == bonus_card_controller.confirmed_locked_field_position:
		if bonus_card_controller.locked_by != "Player":
			return
		else:
			# remove locked field
			selected_field.get_node("Locked").queue_free()
			bonus_card_controller.confirmed_locked_field_position = -1
			bonus_card_controller.locking_field = null
	elif field_position == bonus_card_controller.richard_confirmed_locked_field_position:
		if bonus_card_controller.locked_by2 == "Richard":
			return
	
	# Play card on the field
	create_field_card(field_position, color_name, card_icons[color_name], active_card.get_child(0).text, "Text", true)
	
	# Remove hand and edit cards
	var active_hand_card = edit_to_hand_cards[active_card]
	var score_board_card = active_hand_card.duplicate()
	var score_board_card_preview = create_big_card(color_name, "Preview", active_card.get_child(0).text)
	edit_to_hand_cards.erase(active_card)
	active_hand_card.queue_free()
	active_card.queue_free()
	
	# Calculate points
	point_system_controller.calculate_points(gameboard_fields.find(selected_field), "Player")
	
	# Add Score Screen card
	score_board_card.custom_minimum_size = Vector2(50, 50)
	get_node("ScoreBoard").get_node("ScoreBoardCardsPreview").add_child(score_board_card_preview)
	score_board_card_preview.visible = false
	var option_button = Button.new()
	option_button.custom_minimum_size = Vector2(50, 50)
	option_button.flat = true
	option_button.connect("mouse_entered", func(): _hovering_over_scoreboard_card(score_board_card_preview))
	option_button.connect("mouse_exited", func(): _stop_hovering_over_scoreboard_card(score_board_card_preview))
	score_board_card.add_child(option_button)
	get_node("ScoreBoard").get_node("CardsPlayedByPlayer").add_child(score_board_card)
	
	# Reset active card and playbutton
	active_card = null
	highlighting_controller.highlight_no_fields()
	player_played_bonus_card = false
	player_played_card.emit()

func _hovering_over_scoreboard_card(preview_card):
	preview_card.visible = true

func _stop_hovering_over_scoreboard_card(preview_card):
	preview_card.visible = false

############################################ REFLECTION CARD FOR BEGINNING #########################################################

func play_reflect_card():
	if len(active_card.get_child(0).text) == 0:
		return
	var reflection_field = $ReflectionCardField
	var reflection_card = reflection_field.get_node("Card")
	var reflection_button = reflection_field.get_node("Button")
	reflection_card.get_node("Text").text = active_card.get_child(0).text
	reflection_card.add_theme_stylebox_override("panel", style_boxes["aquamarine"])
	field_to_preview_cards[reflection_card] = create_preview_card(colors[colors.keys()[5]], active_card.get_child(0).text)
	reflection_button.connect("mouse_entered", func(): _hovering_over_button(reflection_button))
	reflection_button.connect("mouse_exited", func(): _stop_hovering_over_button(reflection_button))
	active_card.queue_free()
	active_card = null
	highlighting_controller.highlight_reflect_field_off()
	reflection_card_filled = true
	initiate_gameboard()

############################################ CARD CREATION METHODS #########################################################

func create_hand_card(color, icon_path):
	var new_hand_card = create_small_card(color, "Text", icon_path, card_types[color])
	var new_edit_card = create_edit_card(color)
	var new_button = Button.new()
	new_button.custom_minimum_size = Vector2(35, 35)
	new_button.flat = true
	new_hand_card.add_child(new_button)
	new_button.connect("pressed", func(): _click_hand_card(new_edit_card))
	player_hand_cards.add_child(new_hand_card)
	edit_to_hand_cards[new_edit_card] = new_hand_card

func create_field_card(field_position, color, icon_path, text, type, played_by_player):
	
	# Adjust field card
	var field_card = gameboard_fields[field_position].find_child("Card")
	var field_style_box = style_boxes[color].duplicate()
	field_card.add_theme_stylebox_override("panel", field_style_box)
	if played_by_player:
		field_card.get_theme_stylebox("panel").border_color = player_color
	else:
		field_card.get_theme_stylebox("panel").border_color = richard_color
	var field_label = field_card.find_child("Text")
	field_label.text = text
	var field_icon = field_card.find_child("Icon")
	field_icon.set_texture(load(icon_path))
	
	# Check if text or icon shown
	if type == "Text":
		field_icon.visible = false
	elif type == "Icon":
		field_label.visible = false
	else:
		printerr("Invalid Card Type. Only Label or Icon accepted.")
	
	# preview card and return
	field_card.add_to_group("FieldCard")
	field_to_preview_cards[field_card] = create_preview_card(color, text)
	return field_card

func create_edit_card(color):
	var new_edit_card = create_big_card(color, "Edit", card_types[color])
	player_edit_cards.add_child(new_edit_card)
	return new_edit_card

func create_preview_card(color, text):
	var new_preview_card = create_big_card(color, "Preview", text)
	field_cards_preview.add_child(new_preview_card)
	return new_preview_card

# color = "red" | "yellow" | "green" | "blue" | "grey" | "aquamarine"
# type = "Text" | "Icon"
# icon_path = Path zu Icon-Texture
# text = String an Text für das Label
func create_small_card(color, type, icon_path, text):
	
	# Card Panel
	var new_small_card = Panel.new()
	new_small_card.custom_minimum_size = Vector2(35, 35)
	new_small_card.add_theme_stylebox_override("panel", style_boxes[color])
	new_small_card.size_flags_horizontal = Control.SIZE_SHRINK_CENTER | Control.SIZE_EXPAND
	
	# Card Label
	var new_text_label = Label.new()
	new_text_label.custom_minimum_size = Vector2(600, 600)
	new_text_label.scale = Vector2(0.05, 0.05)
	new_text_label.offset_left = 2
	new_text_label.offset_top = 2
	new_text_label.offset_right = 2
	new_text_label.offset_bottom = 2
	new_text_label.text = text
	new_text_label.add_theme_color_override("background_color", style_boxes[color].bg_color)
	new_text_label.add_theme_color_override("font_color", Color.BLACK)
	new_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	new_text_label.add_theme_font_size_override("font_size", 50)
	new_text_label.clip_text = true
	new_small_card.add_child(new_text_label)
	
	# Card Icon
	var new_icon = TextureRect.new()
	new_icon.texture = load(icon_path)
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
	
	# Only show Label or Icon, not both
	if type == "Text":
		new_icon.visible = false
	elif type == "Icon":
		new_text_label.visible = false
	else:
		printerr("Invalid Card Type. Only Label or Icon accepted.")
	
	return new_small_card

# color = "red" | "yellow" | "green" | "blue" | "grey" | "aquamarine"
# type = "Edit" | "Preview"
# text = String an Text
func create_big_card(color, type, text):
	
	# Card Panel
	var new_big_card = Panel.new()
	new_big_card.custom_minimum_size = Vector2(100, 100)
	new_big_card.add_theme_stylebox_override("panel", style_boxes[color])
	
	# Card TextEdit
	var new_text_edit = TextEdit.new()
	new_text_edit.custom_minimum_size = Vector2(1900, 1900)
	new_text_edit.scale = Vector2(0.05, 0.05)
	new_text_edit.offset_left = 2
	new_text_edit.offset_top = 2
	new_text_edit.offset_right = 2
	new_text_edit.offset_bottom = 2
	new_text_edit.placeholder_text = text
	new_text_edit.add_theme_color_override("background_color", style_boxes[color].bg_color)
	new_text_edit.add_theme_color_override("font_color", Color.BLACK)
	new_text_edit.add_theme_color_override("font_placeholder_color", Color.BLACK)
	new_text_edit.add_theme_font_size_override("font_size", 100)
	new_text_edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	new_big_card.add_child(new_text_edit)
	new_big_card.visible = false
	
	# Only allow to edit on Edit Cards
	if type == "Edit": # Edit Card
		new_text_edit.editable = true
	elif type == "Preview": # Preview Card
		new_text_edit.editable = false
	else:
		printerr("Invalid Card Type. Only Edit or Preview accepted.")
	
	return new_big_card

############################################################################################################################
