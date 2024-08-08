extends Node

var player_nearby = false

func _process(_delta):
	if player_nearby and Input.is_action_just_pressed("interact"):
		SceneSwitcher.switch_scene("res://scenes/tavern.tscn")

func _on_taverne_entry_body_entered(body):
	if body.name == "Player":
		player_nearby = true

func _on_taverne_entry_body_exited(body):
	if body.name == "Player":
		player_nearby = false
