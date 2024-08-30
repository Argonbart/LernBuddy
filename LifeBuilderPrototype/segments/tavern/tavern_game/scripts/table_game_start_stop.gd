extends Area2D

signal table_game_started()
signal table_game_finished()

@onready var table_game = $"../TableGame"
@onready var win_screen_button = $"../PlayerWon/Button"
@onready var ergebnis_screen = $"../ErgebnisScreen"

var player : Node2D
var player_nearby = false

func _ready():
	player = get_tree().get_root().get_node("Player")
	table_game.visible = false
	self.connect("body_entered", player_close)
	self.connect("body_exited", player_not_close)
	self.connect("table_game_started", game_started)
	self.connect("table_game_finished", game_finished)

func _process(_delta):
	if player_nearby and Input.is_action_just_pressed("interact"):
		table_game_started.emit()
	
	if Input.is_action_just_pressed("esc"):
		table_game_finished.emit()

func player_close(body):
	if body.name == "Player":
		player_nearby = true

func player_not_close(body):
	if body.name == "Player":
		player_nearby = false

func game_started():
	player.is_active = false
	player.visible = false
	table_game.visible = true

func game_finished():
	player.is_active = true
	player.visible = true
	table_game.visible = false
	win_screen_button.visible = false
	ergebnis_screen.visible = false
