extends Node

@onready var bonus_card_controller = $"../../BonusCardController"
@onready var table_game = $"../../"

const shader = preload("res://ressources/shader/blinking.material") # shader der panel alpha von 0-255 alteriert
var highlight_fields = []
var highlight_status = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] # 0 = no highlight, 1 = focused, 2 = selected

############################## INITIATE ##################################

func _ready():
	initiate_highlight_fields()

func initiate_highlight_fields():
	for field in self.get_parent().find_child("MarginContainer").find_child("PanelContainer").find_child("Fields").get_children():
		highlight_fields.append(field.get_node("Highlighting"))

############################## PROCESS ##################################

func _process(_delta):
	for i in len(highlight_status):
		var status = highlight_status[i]
		var field = highlight_fields[i]
		if status == 0: # no highlight
			set_field_to_no_highlight(field)
		elif status == 1: # focus
			set_field_to_focus_highlight(field)
		elif status == 2: # selected
			set_field_to_selected_highlight(field)
		else:
			printerr("Illegal Highlight Status!")

############################## BASE ##################################
## focus = blinking highlight to indicate relevance to player
## selection = clicked field, selected for interaction, full panel marked for blinking
##########################################################################

func set_field_to_no_highlight(field): # == 0
	field.add_theme_stylebox_override("panel", load("res://segments/tavern/tavern_game/gameboard_visual_styles/white_border.tres"))
	field.set_material(null)
	field.get_theme_stylebox("panel").border_color.a = 0

func set_field_to_focus_highlight(field): # == 1
	field.add_theme_stylebox_override("panel", load("res://segments/tavern/tavern_game/gameboard_visual_styles/white_border.tres"))
	field.set_material(shader)

func set_field_to_selected_highlight(field): # == 2
	field.add_theme_stylebox_override("panel", load("res://segments/tavern/tavern_game/gameboard_visual_styles/white_panel.tres"))
	field.set_material(shader)

func neutral_field(field):
	if highlight_fields.find(field) != -1:
		highlight_status[highlight_fields.find(field)] = 0

func focus_field(field):
	if highlight_fields.find(field) != -1:
		highlight_status[highlight_fields.find(field)] = 1

func select_field(field):
	if highlight_fields.find(field) != -1:
		highlight_status[highlight_fields.find(field)] = 2

func neutral_all_fields():
	for field in highlight_fields:
		neutral_field(field)

func focus_all_fields():
	for field in highlight_fields:
		focus_field(field)

func select_all_fields():
	for field in highlight_fields:
		select_field(field)

##########################################################################

func focus_all_fields_with_no_lock():
	for field in highlight_fields:
		if field != bonus_card_controller.field_locked_by_player and field != bonus_card_controller.field_locked_by_richard:
			focus_field(field)

func focus_all_fields_with_no_lock_and_card():
	for field in highlight_fields:
		if field.get_parent() != bonus_card_controller.field_locked_by_player and field.get_parent() != bonus_card_controller.field_locked_by_richard:
			if field.get_parent().get_node("Card").get_groups().has("FieldCard"):
				focus_field(field)
			else:
				neutral_field(field)

func focus_fields_with_cards():
	for field in highlight_fields:
		if field.get_parent().get_node("Card").get_groups().has("FieldCard"):
			focus_field(field)
		else:
			neutral_field(field)

func focus_fields_with_no_cards():
	for field in highlight_fields:
		if !field.get_parent().get_node("Card").get_groups().has("FieldCard"):
			focus_field(field)
		else:
			neutral_field(field)

func focus_reflect_field_on():
	var field = $"../../ReflectionCardField".get_node("Highlighting")
	field.add_theme_stylebox_override("panel", load("res://segments/tavern/tavern_game/gameboard_visual_styles/white_border.tres"))
	field.set_material(shader)

func focus_reflect_field_off():
	var field = $"../../ReflectionCardField".get_node("Highlighting")
	field.add_theme_stylebox_override("panel", load("res://segments/tavern/tavern_game/gameboard_visual_styles/white_border.tres"))
	field.set_material(null)
	field.get_theme_stylebox("panel").border_color.a = 0

############################## JOKER ##################################

func joker_clicked():
	neutral_all_fields()
	focus_fields_with_cards()

func joker_canceled():
	neutral_all_fields()

func joker_field_selected():
	neutral_all_fields()
	if bonus_card_controller.joker_field_to_delete:
		select_field(bonus_card_controller.joker_field_to_delete.get_node("Highlighting"))

func joker_execute():
	neutral_field(bonus_card_controller.joker_field_to_delete.get_node("Highlighting"))

############################## SWITCH ##################################

func switch_clicked():
	neutral_all_fields()
	focus_all_fields_with_no_lock_and_card()

func switch_canceled():
	neutral_all_fields()

func switch_first_card_selected():
	focus_all_fields_with_no_lock()
	select_field(bonus_card_controller.first_switch_field.get_node("Highlighting"))

func switch_second_card_selected():
	neutral_all_fields()
	select_field(bonus_card_controller.first_switch_field.get_node("Highlighting"))
	select_field(bonus_card_controller.second_switch_field.get_node("Highlighting"))

func switch_executed():
	neutral_field(bonus_card_controller.first_switch_field.get_node("Highlighting"))
	neutral_field(bonus_card_controller.second_switch_field.get_node("Highlighting"))

############################## DOUBLE POINTS ##################################

func doublepoints_clicked():
	focus_all_fields()

func doublepoints_canceled():
	neutral_all_fields()
	if bonus_card_controller.double_field:
		neutral_field(bonus_card_controller.double_field.get_node("Highlighting"))

func doublepoints_selected():
	neutral_all_fields()
	select_field(bonus_card_controller.double_field.get_node("Highlighting"))

func doublepoints_executed():
	neutral_field(bonus_card_controller.double_field.get_node("Highlighting"))

############################## LOCK ##################################

func lock_clicked():
	focus_all_fields()

func lock_canceled():
	neutral_all_fields()
	if bonus_card_controller.field_locked_by_player:
		neutral_field(bonus_card_controller.field_locked_by_player.get_node("Highlighting"))

func lock_selected():
	neutral_all_fields()
	select_field(bonus_card_controller.field_locked_by_player.get_node("Highlighting"))

func lock_executed():
	neutral_field(bonus_card_controller.field_locked_by_player.get_node("Highlighting"))

func bonus_card_played():
	neutral_all_fields()

############################## REFLECT CARD ##################################

func reflection_card_start():
	focus_reflect_field_on()

func reflection_card_end():
	focus_reflect_field_off()

############################## NORMAL CARD PLAY ##################################

func field_selected(field):
	neutral_all_fields()
	select_field(field)

func handcard_selected():
	focus_fields_with_no_cards()

func handcard_not_selected():
	neutral_all_fields()

func card_played():
	neutral_field(table_game.last_selected_field)
	neutral_all_fields()

######################################################################
