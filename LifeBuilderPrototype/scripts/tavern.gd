extends Node

@onready var player : Node2D

var player_nearby = false

func _ready():
	player = get_tree().get_root().get_node("Player")

func _process(_delta):
	if player_nearby and Input.is_action_just_pressed("interact"):
		SceneSwitcher.switch_scene("res://scenes/tavern.tscn")
		player.position = Vector2(260, 570)
		player.scale = Vector2(2.0, 2.0)
		player.speed = 300

func _on_taverne_entry_body_entered(body):
	if body.name == "Player":
		player_nearby = true

func _on_taverne_entry_body_exited(body):
	if body.name == "Player":
		player_nearby = false
