extends Area2D

signal jana_dialogue_toggled()

@onready var talia_dialogue = $"../DialogueWindow"

var player : Node2D
var player_nearby : bool

var jana_dialogue_active = false

func _ready():
	player = get_tree().get_root().get_node("Player")
	player_nearby = false
	self.connect("body_entered", player_close)
	self.connect("body_exited", player_not_close)
	self.connect("jana_dialogue_toggled", player.dialogue_toggled)
	initiate_elric_dialogue()

func initiate_elric_dialogue():
	talia_dialogue.set_npc("Jana", Color("#f9f500"))
	talia_dialogue.set_text("Ich bin Jana!\nWillst du zur Reflektionskarte?\nYes(Press Y) or No(Press N)?")

func _process(_delta):
	if player_nearby and Input.is_action_just_pressed("interact"):
		talia_dialogue.toggle_dialogue()
		jana_dialogue_toggled.emit()
		jana_dialogue_active = true
		
	if jana_dialogue_active and Input.is_key_pressed(KEY_Y):
		SceneSwitcher.switch_scene("res://segments/hexagons/scenes/hexagon_field.tscn")
		get_viewport().content_scale_size = Vector2i(1920, 1200)
		player.position = Vector2(10000, 10000)
		player.scale = Vector2(2.0, 2.0)
		player.speed = 300
		talia_dialogue.toggle_dialogue()
		jana_dialogue_toggled.emit()
		jana_dialogue_active = false
		
	if jana_dialogue_active and Input.is_key_pressed(KEY_N):
		talia_dialogue.toggle_dialogue()
		jana_dialogue_toggled.emit()
		jana_dialogue_active = false

func player_close(body):
	if body.name == "Player":
		player_nearby = true

func player_not_close(body):
	if body.name == "Player":
		player_nearby = false
