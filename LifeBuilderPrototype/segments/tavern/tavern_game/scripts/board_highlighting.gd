extends Node

@onready var bonus_card_controller = $"../../BonusCardController"
@onready var table_game = $"../../"

const shader = preload("res://ressources/shader/blinking.material") # shader der panel alpha von 0-255 alteriert
var highlight_fields

############################## INITIATE ##################################

func _ready():
	initiate_highlight_fields()

func initiate_highlight_fields():
	highlight_fields = {}
	var fields_node = self.get_parent().find_child("MarginContainer").find_child("PanelContainer").find_child("Fields")
	for field in fields_node.get_children():
		for child in field.get_children():
			if child.get_groups().has("HighlightPanel"):
				highlight_fields[field] = child

############################## INITIATE ##################################
## focus = blinking highlight to indicate relevance to player
## selection = clicked field, selected for interaction, full panel marked for blinking
##########################################################################

func focus_field_on(field):
	field.set_material(shader)
	field.get_theme_stylebox("panel").border_color.a = 255
	field.visible = true

func focus_field_off(field):
	field.set_material(null)
	field.get_theme_stylebox("panel").border_color.a = 0
	field.visible = false

func focus_all_fields_on():
	for field in highlight_fields.values():
		focus_field_on(field)

func focus_all_fields_off():
	for field in highlight_fields.values():
		focus_field_off(field)

func selection_field_on(field):
	var panel = field.get_node("Highlighting")
	var new_stylebox = panel.get_theme_stylebox("panel").duplicate()
	new_stylebox.bg_color = Color("#ffffff")
	panel.add_theme_stylebox_override("panel", new_stylebox)
	panel.set_material(shader)
	panel.visible = true

func selection_field_off(field):
	var panel = field.get_node("Highlighting")
	panel.add_theme_stylebox_override("panel", load("res://segments/tavern/tavern_game/gameboard_visual_styles/highlighting.tres"))
	panel.set_material(null)
	panel.visible = false

func selection_all_fields_on():
	for field in highlight_fields:
		selection_field_on(field)

func selection_all_fields_off():
	for field in highlight_fields:
		selection_field_off(field)

##########################################################################

func focus_all_fields_with_no_lock():
	for field in highlight_fields.values():
		if field != bonus_card_controller.field_locked_by_player and field != bonus_card_controller.field_locked_by_richard:
			focus_field_on(field)

func focus_all_fields_with_no_lock_and_card():
	for field in highlight_fields.keys():
		var field_highlight = field.get_node("Highlighting")
		if field != bonus_card_controller.field_locked_by_player and field != bonus_card_controller.field_locked_by_richard:
			if field.get_node("Card").get_groups().has("FieldCard"):
				focus_field_on(field_highlight)
			else:
				focus_field_off(field_highlight)

func focus_fields_with_cards():
	for field in highlight_fields.keys():
		if field.get_node("Card").get_groups().has("FieldCard"):
			focus_field_on(highlight_fields[field])
		else:
			focus_field_off(highlight_fields[field])

func focus_fields_with_no_cards():
	for field in highlight_fields.keys():
		if field.get_node("Card").get_groups().has("FieldCard"):
			focus_field_off(highlight_fields[field])
		else:
			focus_field_on(highlight_fields[field])

func focus_reflect_field_on():
	focus_field_on($"../../ReflectionCardField".get_node("Highlighting"))

func focus_reflect_field_off():
	focus_field_off($"../../ReflectionCardField".get_node("Highlighting"))

############################## JOKER ##################################

func joker_clicked():
	selection_all_fields_off()
	focus_all_fields_off()
	focus_fields_with_cards()

func joker_canceled():
	focus_all_fields_off()
	selection_all_fields_off()

func joker_field_selected():
	selection_all_fields_off()
	if bonus_card_controller.joker_field_to_delete:
		selection_field_on(bonus_card_controller.joker_field_to_delete)

func joker_execute():
	selection_field_off(bonus_card_controller.joker_field_to_delete)

############################## SWITCH ##################################

func switch_clicked():
	selection_all_fields_off()
	focus_all_fields_off()
	focus_all_fields_with_no_lock_and_card()

func switch_canceled():
	focus_all_fields_off()
	selection_all_fields_off()

func switch_first_card_selected():
	focus_all_fields_with_no_lock()
	selection_field_on(bonus_card_controller.first_switch_field)

func switch_second_card_selected():
	focus_all_fields_off()
	selection_field_on(bonus_card_controller.first_switch_field)
	selection_field_on(bonus_card_controller.second_switch_field)

func switch_executed():
	selection_field_off(bonus_card_controller.first_switch_field)
	selection_field_off(bonus_card_controller.second_switch_field)

############################## DOUBLE POINTS ##################################

func doublepoints_clicked():
	selection_all_fields_off()
	focus_all_fields_on()

func doublepoints_canceled():
	focus_all_fields_off()
	if bonus_card_controller.double_field:
		selection_field_off(bonus_card_controller.double_field)

func doublepoints_selected():
	selection_all_fields_off()
	selection_field_on(bonus_card_controller.double_field)

func doublepoints_executed():
	selection_field_off(bonus_card_controller.double_field)

############################## LOCK ##################################

func lock_clicked():
	selection_all_fields_off()
	focus_all_fields_on()

func lock_canceled():
	focus_all_fields_off()
	if bonus_card_controller.field_locked_by_player:
		selection_field_off(bonus_card_controller.field_locked_by_player)

func lock_selected():
	selection_all_fields_off()
	selection_field_on(bonus_card_controller.field_locked_by_player)

func lock_executed():
	selection_field_off(bonus_card_controller.field_locked_by_player)

func bonus_card_played():
	selection_all_fields_off()

############################## REFLECT CARD ##################################

func reflection_card_start():
	selection_all_fields_off()
	focus_reflect_field_on()

func reflection_card_end():
	focus_reflect_field_off()

############################## NORMAL CARD PLAY ##################################

func field_selected(field):
	if table_game.last_selected_field:
		selection_field_off(table_game.last_selected_field)
	table_game.last_selected_field = field
	selection_field_on(table_game.last_selected_field)

func handcard_selected():
	focus_fields_with_no_cards()

func handcard_not_selected():
	selection_all_fields_off()

func card_played():
	selection_field_off(table_game.last_selected_field)
	selection_all_fields_off()

######################################################################
