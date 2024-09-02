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

func highlight_all_fields():
	for panel in highlight_fields.values():
		panel.set_material(shader)

func highlight_no_fields():
	for panel in highlight_fields.values():
		panel.set_material(null)

func highlight_fields_with_cards():
	for field in highlight_fields.keys():
		if field_has_card(field):
			highlight_fields[field].set_material(shader)
		else:
			highlight_fields[field].set_material(null)

func highlight_empty_fields():
	for field in highlight_fields.keys():
		if field_has_card(field):
			highlight_fields[field].set_material(null)
		else:
			highlight_fields[field].set_material(shader)

func field_has_card(field):
	for child in field.get_children():
		if child.get_groups().has("FieldCard"):
			return true
	return false

func highlight_reflect_field_on():
	$"../../ReflectionCardField".get_node("Highlighting").set_material(shader)

func highlight_reflect_field_off():
	$"../../ReflectionCardField".get_node("Highlighting").set_material(null)
