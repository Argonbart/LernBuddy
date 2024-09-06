extends Node

const shader = preload("res://ressources/shader/blinking.material")
var highlight_fields

func _ready():
	initiate_highlight_fields()

func initiate_highlight_fields():
	highlight_fields = {}
	var fields_node = self.get_parent().find_child("MarginContainer").find_child("PanelContainer").find_child("Fields")
	for field in fields_node.get_children():
		for child in field.get_children():
			if child.get_groups().has("HighlightPanel"):
				highlight_fields[field] = child

func highlight_field_on(panel):
	panel.set_material(shader)
	panel.get_theme_stylebox("panel").border_color.a = 255
	panel.visible = true

func highlight_field_off(panel):
	panel.set_material(null)
	panel.get_theme_stylebox("panel").border_color.a = 0
	panel.visible = false

func highlight_all_fields():
	for panel in highlight_fields.values():
		highlight_field_on(panel)

func highlight_no_fields():
	for panel in highlight_fields.values():
		highlight_field_off(panel)

func highlight_fields_with_cards():
	for field in highlight_fields.keys():
		if field_has_card(field):
			highlight_field_on(highlight_fields[field])
		else:
			highlight_field_off(highlight_fields[field])

func highlight_empty_fields():
	for field in highlight_fields.keys():
		if field_has_card(field):
			highlight_field_off(highlight_fields[field])
		else:
			highlight_field_on(highlight_fields[field])

func field_has_card(field):
	for child in field.get_children():
		if child.get_groups().has("FieldCard"):
			return true
	return false

func highlight_reflect_field_on():
	highlight_field_on($"../../ReflectionCardField".get_node("Highlighting"))

func highlight_reflect_field_off():
	highlight_field_off($"../../ReflectionCardField".get_node("Highlighting"))

func highlight_no_bonus_cards():
	for element in get_parent().get_node("MarginContainer/PanelContainer/Fields").get_children():
		highlight_bonus_card_off(element)

func highlight_bonus_card_on(field):
	var panel = field.get_node("Highlighting")
	var new_stylebox = panel.get_theme_stylebox("panel").duplicate()
	new_stylebox.bg_color = Color("#ffffff")
	panel.add_theme_stylebox_override("panel", new_stylebox)
	panel.set_material(shader)
	panel.visible = true

func highlight_bonus_card_off(field):
	var panel = field.get_node("Highlighting")
	panel.add_theme_stylebox_override("panel", load("res://segments/tavern/tavern_game/gameboard_visual_styles/highlighting.tres"))
	panel.set_material(null)
	panel.visible = false
