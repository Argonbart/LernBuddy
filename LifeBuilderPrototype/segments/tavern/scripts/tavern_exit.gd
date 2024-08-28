extends Node

@onready var player : Node2D

var player_nearby = false

func _ready():
	player = get_tree().get_root().get_node("Player")

func _process(_delta):
	if player_nearby and Input.is_action_just_pressed("interact"):
		SceneSwitcher.switch_scene("res://segments/village/scenes/village.tscn")
		player.position = Vector2(65, 40)
		player.scale = Vector2(1.0, 1.0)
		player.speed = 200

func _on_body_entered(body):
	if body.name == "Player":
		player_nearby = true

func _on_body_exited(body):
	if body.name == "Player":
		player_nearby = false
