extends Area2D

var player : Node2D
var player_nearby : bool

func _ready():
	player = get_tree().get_root().get_node("Player")
	player_nearby = false
	self.connect("body_entered", player_close)
	self.connect("body_exited", player_not_close)

func _process(_delta):
	if player_nearby and Input.is_action_just_pressed("interact"):
		SceneSwitcher.switch_scene("res://segments/village/scenes/village.tscn")
		player.position = Vector2(65, 40)
		player.scale = Vector2(1.0, 1.0)
		player.speed = 200

func player_close(body):
	if body.name == "Player":
		player_nearby = true

func player_not_close(body):
	if body.name == "Player":
		player_nearby = false
