extends Control

@onready var name_label = $VBoxContainer/HBoxContainer/NamePanel/NameLabel
@onready var text_label = $VBoxContainer/NamePanel/MarginContainer/TextLabel

func set_npc(npc_name, npc_color):
	name_label.text = npc_name
	name_label.set("theme_override_colors/font_color", npc_color)

func set_text(npc_text):
	text_label.text = npc_text

func show_dialogue():
	visible = true

func hide_dialogue():
	visible = false
