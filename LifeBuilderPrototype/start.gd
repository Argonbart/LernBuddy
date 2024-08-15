extends Node

func _ready():
	var player_scene = preload("res://scenes/player.tscn")
	var player = player_scene.instantiate()
	get_tree().root.add_child.call_deferred(player)
	SceneSwitcher.switch_scene("res://scenes/world.tscn")
	player.position = Vector2(-130, 70)
	player.scale = Vector2(1.0, 1.0)
	player.speed = 200
