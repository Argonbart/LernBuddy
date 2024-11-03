extends Area2D

signal richard_dialogue_toggled()

@onready var richard_dialogue = $"../DialogueWindow"

var player : Node2D
var player_nearby : bool

var richard_dialogue_active = false

func _ready():
	player = get_tree().get_root().get_node("Player")
	player_nearby = false
	self.connect("body_entered", player_close)
	self.connect("body_exited", player_not_close)
	self.connect("richard_dialogue_toggled", player.dialogue_toggled)
	initiate_elric_dialogue()

func initiate_elric_dialogue():
	richard_dialogue.set_npc("Richard", Color("#9a70ff"))
	richard_dialogue.set_text("Ich bin Richard!\nWillst du eine Runde Reflektions-Karten mit mir spielen?\nYes(Press Y) or No(Press N)?")

func _process(_delta):
	if player_nearby and Input.is_action_just_pressed("interact"):
		richard_dialogue.toggle_dialogue()
		richard_dialogue_toggled.emit()
		richard_dialogue_active = true
		
	if richard_dialogue_active and Input.is_key_pressed(KEY_Y):
		GeminiAPI.start_richard_game()
		SceneSwitcher.switch_scene("res://segments/tavern_game/scenes/table_game.tscn")
		player.position = Vector2(900, 380)
		player.scale = Vector2(2.0, 2.0)
		player.speed = 300
		richard_dialogue.toggle_dialogue()
		richard_dialogue_toggled.emit()
		richard_dialogue_active = false
		
	if richard_dialogue_active and Input.is_key_pressed(KEY_N):
		richard_dialogue.toggle_dialogue()
		richard_dialogue_toggled.emit()
		richard_dialogue_active = false

func player_close(body):
	if body.name == "Player":
		player_nearby = true

func player_not_close(body):
	if body.name == "Player":
		player_nearby = false
