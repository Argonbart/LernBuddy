extends Node

@onready var return_to_tavern_button = $ReturnToTavernButton
@onready var player : Node2D

func _ready():
	player = get_tree().get_root().get_node("Player")
	return_to_tavern_button.connect("button_up", func(): _return_to_tavern())

func _return_to_tavern():
	SceneSwitcher.switch_scene("res://segments/tavern/scenes/tavern.tscn")
	player.position = Vector2(850, 330)
	player.scale = Vector2(2.0, 2.0)
	player.speed = 300
