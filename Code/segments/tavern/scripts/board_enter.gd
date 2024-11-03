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
		SceneSwitcher.switch_scene("res://segments/tavern_board/scenes/tavern_board.tscn")
		player.position = Vector2(500, 500)
		player.scale = Vector2(1.0, 1.0)
		player.speed = 0.05

func player_close(body):
	if body.name == "Player":
		player_nearby = true

func player_not_close(body):
	if body.name == "Player":
		player_nearby = false
