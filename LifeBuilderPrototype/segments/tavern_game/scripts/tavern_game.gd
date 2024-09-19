extends Node

############################################ VARIABLES #########################################################

signal player_played_card()

# Nodes
@onready var highlighting_controller = $GameBoard/HighlightController	# Handles all highlighting
@onready var point_system_controller = $PointSystemController			# Handles all point calculation
@onready var bonus_card_controller = $BonusCardController				# Handles all bonus cards
@onready var player_deck = $"../TableGame/Deck"							# Bonus-card deck
@onready var player_hand_cards = $"../TableGame/PlayerCards"			# Players hand cards
@onready var field_cards_preview = $"../TableGame/BigCardsOnField"		# Preview cards (left)
@onready var player_edit_cards = $"../TableGame/EditCards"				# Edit cards (right)
@onready var play_card_button = $GameBoard/PlayCardButton				# Button to play card
@onready var end_turn_button = $GameBoard/EndTurnButton					# Button to end turn after normal card (if bonus card not played yet)
@onready var play_reflect_card_button = $ReflectionCardField/Button		# Button to play reflect card
@onready var draw_card_button											# Button to draw bonus-card
@onready var richard_text_box = $RichardTextBox							# Richard Text Bubble
@onready var player_hand_image = $PlayerHand							# Player Hand PNG
@onready var player_hand_with_card_image = $PlayerHandWithCard			# Player Hand With Card PNG
@onready var richard = $Richard											# Richard play logic script
@onready var scrollable_text_edit : TextEdit = $Useless

# Static card data
var style_boxes

# Textures for alternative style boxes
#var card_textures = {"res://ressources/icons/face.svg": "red",
					 #"res://ressources/icons/thumb.svg": "yellow",
					 #"res://ressources/icons/bulb.svg": "green",
					 #"res://ressources/icons/note.svg": "blue",
					 #"res://ressources/icons/lock.svg": "grey",
					 #"res://ressources/icons/switch.svg": "aquamarine"}

# Colors used
var colors = {Color("#ea4d53"): "red",
			  Color("#ebbc6d"): "yellow",
			  Color("#328948"): "green",
			  Color("#554dc9"): "blue",
			  Color("#989595"): "grey",
			  Color("#7fffd4"): "aquamarine"}
var player_color = Color("#000000")
var richard_color = Color("#FFFFFF")

# Card texts (grey bonus cards get text based on effect)
var card_types = {"red":    "EMOTIONEN\nWie fühlst du dich in Bezug auf das Reflexionsthema? Welche Emotionen wurden bei dir ausgelöst, oder welche empfindest du jetzt noch?\n[ Schreib hier rein.. ]",
				  "yellow": "FAKTEN\nWelche neutralen Informationen, Daten, Hintergründe, etc. gehören zu deinem Reflexionsthema?\n[ Schreib hier rein.. ]",
				  "green":  "OPTIMISMUS\nWelche Vorteile und Möglichkeiten eröffnen sich durch das Reflexionsthema?\n[ Schreib hier rein.. ]",
				  "blue":   "KREATIVITÄT\nWas sind weitere Assoziationen mit deinem Reflexionsthema? Welche Chancen für die Zukunft, oder unerwartete Zusammenhänge kann es geben?\n[ Schreib hier rein.. ]",
				  "aquamarine": "REFLEKTION\nWorüber möchtest du diese Runde reflektieren? Schreibe dein Thema auf.\n[ Schreib hier rein.. ]"}

# Card icons (grey bonus cards get icons based on effect, aquamarine does not need an icon)
var card_icons = {"red":    "res://ressources/icons/face.svg",
				  "yellow": "res://ressources/icons/note.svg",
				  "green":  "res://ressources/icons/thumb.svg",
				  "blue":   "res://ressources/icons/bulb.svg"}

# Bonus card effect text
var bonus_card_effects = {"joker": "Mit Color Joker wird eine Perspektivenkarte des Gegenspielers aus dem Spiel entfernt. Außerdem bekommt der/die ausspielende Spieler*in eine neue Perspektivenkarte beliebigen Typs auf die Hand.",
						# Entferne eine gegnerische Karte aus dem Spiel und bekomme eine beliebige Perspektivenkarte auf die Hand.
						  "switch": "Mit Switch wird eine beliebige Perspektivenkarte auf dem Spielbrett ausgewählt, und auf ein anderes (nicht abgeschlossenes) Feld gespielt. Dabei sind 2 Fälle zu unterscheiden. 1) Wenn das gewählte Feld für die Perspektivenkarte leer ist, wird sie auf die Position des leeren Feldes gelegt. 2) Wenn das gewählte Feld für die Perspektivenkarte bereits belegt ist, werden die Positionen der beiden Karten vertauscht.", 
						# Wähle eine Karte und tausche die Position mit einem nicht gelockten Feld (andere Karte oder leeres Feld).
						  "doublepoints": "Ein Feld mit Doppelte Punkte verdoppelt die erzielten Punkte, welche dieses Feld involvieren. Auf dem Spielbrett kann dieser Effekt von beiden Spieler*innen genutzt werden.",
						# Spiele diese Karte auf ein Feld. Alle mit diesem Feld verdienten Punkte werden verdoppelt.
						  "lock":  "Mit Lock wird ein Feld abgeschlossen. Ein abgeschlossenes Feld ist vor den Effekten von Switch und Color Joker geschützt. Wenn Lock auf ein leeres Feld gespielt wird, darf nur der/die Besitzer*in der Lock Karte darauf eine Perspektivenkarte spielen."}
						# Reserviere ein leeres Feld für dich, der Gegner kann darauf keine Karte spielen.\n\nODER\n\nSperre eine Karte. Gesperrte Karten können nicht entfernt oder bewegt werden.

# Bonus card icons
var bonus_card_icons = {"joker": "res://ressources/icons/joker.svg",
						 "switch": "res://ressources/icons/switch.svg", 
						 "doublepoints": "res://ressources/icons/doublepoints.png",
						 "lock": "res://ressources/icons/lock.svg",
						 "quadropoints": "res://ressources/icons/quadropoints.png"}

# information for game
var gameboard_fields : Array
var last_selected_field : ReferenceRect = null
var currently_shown_edit_card : Panel = null
var edit_to_hand_cards : Dictionary = {}
var field_to_preview_cards : Dictionary = {}
var bonus_cards : Dictionary = {}
var player_bonus_card_effects : Array
var reflection_card_filled : bool = false
var reflect_field_is_selected : bool = false

var normal_card_played : bool = false
var bonus_card_played : bool = false

# bonus card variables
var switch_ongoing : bool = false
var joker_ongoing : bool = false
var doublepoints_ongoing : bool = false
var lock_ongoing : bool = false
var player_played_bonus_card : bool = false

# points
var player_points : int = 0
var richard_points : int = 0

# timing
var turn_time = 1.0

############################################ PROCESS #########################################################

func _process(_delta):
	# Update text for hand cards according to edit
	for edit_card in edit_to_hand_cards.keys():
		var edit_card_text = edit_card.get_child(0).text
		if len(edit_card_text) == 0:
			edit_to_hand_cards[edit_card].get_child(1).visible = true
			edit_to_hand_cards[edit_card].get_child(0).text = ""
		else:
			edit_to_hand_cards[edit_card].get_child(1).visible = false
			edit_to_hand_cards[edit_card].get_child(0).text = edit_card_text

# To Scroll through active big cards if text too long
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			scrollable_text_edit.scroll_vertical += 10
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			scrollable_text_edit.scroll_vertical -= 10

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
	#for texture in card_textures:
		#var new_style_box = StyleBoxTexture.new()
		#new_style_box.texture = load(texture)
		#style_boxes[card_textures[texture]] = new_style_box

# Prepare fields with buttons
func initiate_field_buttons():
	gameboard_fields = self.find_child("GameBoard").find_child("MarginContainer").find_child("PanelContainer").find_child("Fields").get_children()
	for field in gameboard_fields:
		field.find_child("Card").size_flags_horizontal = Control.SIZE_SHRINK_CENTER | Control.SIZE_EXPAND
		var field_button = field.find_child("Button")
		field_button.connect("focus_entered", func(): _field_selected(field_button))
		field_button.connect("focus_exited", func(): _field_deselected(field_button))
		field_button.connect("mouse_entered", func(): _hovering_over_button(field_button))
		field_button.connect("mouse_exited", func(): _stop_hovering_over_button(field_button))
	play_card_button.connect("button_up", func(): _play_card_button_pressed())
	end_turn_button.connect("button_up", func(): _end_turn_without_playing_bonus_card())
	play_reflect_card_button.connect("button_down", func(): _field_selected(play_reflect_card_button))
	richard.connect("richard_finished_turn", func(): _richard_finished_turn())

# Prepare reflection card
func initiate_reflection_card():
	var reflection_card_edit = create_edit_card(colors[colors.keys()[5]])
	reflection_card_edit.visible = true
	currently_shown_edit_card = reflection_card_edit
	highlighting_controller.reflection_card_start()

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

############################################ BUTTONS #########################################################

# Clicked on field button
func _field_selected(button):
	var field = button.get_parent()
	
	# Before reflection card was played
	if !reflection_card_filled:
		if button == play_reflect_card_button:
			reflect_field_is_selected = true
			play_card_button.visible = true
		else:
			reflect_field_is_selected = false
			play_card_button.visible = false
		return
	
	# Update bonus card field if bonus card ongoing
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
	
	last_selected_field = field
	
	# Set current field variables
	if !joker_ongoing and !switch_ongoing and !doublepoints_ongoing and !lock_ongoing and currently_shown_edit_card != null:
		play_card_button.visible = true
		point_system_controller.preview_move(field)
	
	# Selected field visualisation
	highlighting_controller.field_selected(last_selected_field.get_node("Highlighting"))

# Clicked away from field button
func _field_deselected(button):
	button.get_parent().get_node("PreviewPoints").text = ""

# Start hovering over field button
func _hovering_over_button(button):
	var field_card = button.get_parent().get_node("Card")
	if field_card.get_groups().has("FieldCard"):
		field_to_preview_cards[field_card].visible = true
		scrollable_text_edit = field_to_preview_cards[field_card].get_child(0)

# Stop hovering over field button
func _stop_hovering_over_button(button):
	var field_card = button.get_parent().get_node("Card")
	if field_card.get_groups().has("FieldCard"):
		field_to_preview_cards[field_card].visible = false

############################################ PLAYER #########################################################

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

# Click on deck to see next bonus card
func _show_next_bonus_card():
	
	# Bonus card already played this turn
	if player_played_bonus_card:
		return
	
	# No bonus cards left
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

# Hand card clicked
func _click_hand_card(edit_card):
	if switch_ongoing:
		bonus_card_controller.cancel_switch()
	if joker_ongoing:
		bonus_card_controller.cancel_joker()
	if doublepoints_ongoing:
		bonus_card_controller.cancel_doublepoints()
	if lock_ongoing:
		bonus_card_controller.cancel_lock()
	update_edit_cards(edit_card)

# Update showing edit card
func update_edit_cards(edit_card):
	for card in player_edit_cards.get_children():
		if card == edit_card:
			edit_card.visible = !edit_card.visible
			if edit_card.visible:
				edit_card.get_child(0).grab_focus()
				currently_shown_edit_card = edit_card
				if last_selected_field != null:
					play_card_button.visible = true
				highlighting_controller.handcard_selected()
			else:
				currently_shown_edit_card = null
				play_card_button.visible = false
				highlighting_controller.handcard_not_selected()
		else:
			card.visible = false

############################################ PLAYING CARD #########################################################

# PlayButton pressed
func _play_card_button_pressed():
	
	# Play reflection card if not played yet
	if !reflection_card_filled:
		play_reflect_card()
		return
	
	if colors[currently_shown_edit_card.get_theme_stylebox("panel").bg_color] == "grey":
		if bonus_card_controller.confirm_bonus_card_play():
			bonus_card_controller.currently_playing("Player")
			bonus_card_controller.execute_bonus_card()
			update_edit_cards(currently_shown_edit_card)
			return
	
	if last_selected_field and !last_selected_field.get_node("Card").get_groups().has("FieldCard") and !normal_card_played:
		var first_tween = create_tween()
		highlighting_controller.card_played()
		get_node("RichardsTurnPanel").visible = true
		first_tween.tween_property(player_hand_with_card_image, "position", Vector2(gameboard_fields[gameboard_fields.find(last_selected_field)].position.x, gameboard_fields[gameboard_fields.find(last_selected_field)].position.y), 0.8 * turn_time)
		first_tween.connect("finished", func(): _play_card_tween_finished())
	else:
		print("This move is not allowed!")

func _play_card_tween_finished():
	await get_tree().create_timer(0.2 * turn_time).timeout
	player_hand_with_card_image.position = Vector2(130, 200)
	play_card()
	get_node("RichardsTurnPanel").visible = false

# Card played
func play_card():
	
	# check if card text is empty
	if len(currently_shown_edit_card.get_child(0).text) == 0:
		show_message("Please type something on the card!")
		return
	
	var field_position = gameboard_fields.find(last_selected_field)
	var color_name = colors[currently_shown_edit_card.get_theme_stylebox("panel").bg_color]
	
	# Check for lock
	if field_position == bonus_card_controller.confirmed_locked_field_position:
		if bonus_card_controller.locked_by != "Player":
			return
		else:
			# remove locked field
			last_selected_field.get_node("LockedByPlayer").queue_free()
			bonus_card_controller.confirmed_locked_field_position = -1
			bonus_card_controller.field_locked_by_player = null
	elif field_position == bonus_card_controller.richard_confirmed_locked_field_position:
		if bonus_card_controller.locked_by2 == "Richard":
			return
	
	# Play card on the field
	create_field_card(field_position, color_name, card_icons[color_name], currently_shown_edit_card.get_child(0).text, "Text", true)
	
	# Remove hand and edit cards
	var active_hand_card = edit_to_hand_cards[currently_shown_edit_card]
	var score_board_card = active_hand_card.duplicate()
	var score_board_card_preview = create_big_card(color_name, "Preview", currently_shown_edit_card.get_child(0).text)
	edit_to_hand_cards.erase(currently_shown_edit_card)
	active_hand_card.queue_free()
	currently_shown_edit_card.queue_free()
	
	# Calculate points
	point_system_controller.calculate_points(gameboard_fields.find(last_selected_field), "Player")
	
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
	currently_shown_edit_card = null
	play_card_button.visible = false
	highlighting_controller.card_played()
	last_selected_field = null
	player_played_bonus_card = false
	end_turn_button.visible = true
	normal_card_played = true
	if bonus_card_played:
		end_turn()

func _end_turn_without_playing_bonus_card():
	end_turn()

func end_turn():
	end_turn_button.visible = false
	player_played_card.emit()

func _richard_finished_turn():
	normal_card_played = false
	bonus_card_played = false
	show_message("Your Turn!")

func _hovering_over_scoreboard_card(preview_card):
	preview_card.visible = true

func _stop_hovering_over_scoreboard_card(preview_card):
	preview_card.visible = false

############################################ REFLECTION CARD FOR BEGINNING #########################################################

func play_reflect_card():
	
	if len(currently_shown_edit_card.get_child(0).text) == 0:
		print("Please type something on the card!")
		return
	
	var reflection_field = $ReflectionCardField
	var reflection_card = reflection_field.get_node("Card")
	var reflection_button = reflection_field.get_node("Button")
	reflection_card.get_node("Text").text = currently_shown_edit_card.get_child(0).text
	reflection_card.add_theme_stylebox_override("panel", style_boxes["aquamarine"])
	field_to_preview_cards[reflection_card] = create_preview_card(colors[colors.keys()[5]], currently_shown_edit_card.get_child(0).text)
	reflection_button.connect("mouse_entered", func(): _hovering_over_button(reflection_button))
	reflection_button.connect("mouse_exited", func(): _stop_hovering_over_button(reflection_button))
	reflection_button.disabled = true
	currently_shown_edit_card.queue_free()
	currently_shown_edit_card = null
	play_card_button.visible = false
	highlighting_controller.reflection_card_end()
	reflection_card_filled = true
	initiate_gameboard()

######################

func show_message(new_text):
	richard_text_box.get_node("Panel").get_node("Label").text = new_text
	richard_text_box.visible = true
	await get_tree().create_timer(2.0).timeout
	richard_text_box.visible = false

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
	new_text_edit.caret_type = TextEdit.CARET_TYPE_BLOCK
	new_text_edit.caret_blink = true
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
