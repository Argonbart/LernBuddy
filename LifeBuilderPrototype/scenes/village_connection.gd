extends Node2D

var dialogue_active = false

func _on_blacksmith_dialogue_started():
	dialogue_active = true

func _on_blacksmith_dialogue_finished():
	dialogue_active = false

func _on_phantom_dialogue_started():
	dialogue_active = true

func _on_phantom_dialogue_finished():
	dialogue_active = false

func _on_mayor_dialogue_started():
	dialogue_active = true

func _on_mayor_dialogue_finished():
	dialogue_active = false
