extends Area2D

signal talia_dialogue_toggled()

@onready var talia_dialogue = $"../DialogueWindow"

var player : Node2D
var player_nearby : bool

func _ready():
	player = get_tree().get_root().get_node("Player")
	player_nearby = false
	self.connect("body_entered", player_close)
	self.connect("body_exited", player_not_close)
	self.connect("talia_dialogue_toggled", player.dialogue_toggled)
	initiate_elric_dialogue()

func initiate_elric_dialogue():
	talia_dialogue.set_npc("Talia", Color("#f9f500"))
	talia_dialogue.set_text("Ich bin Talia!")

func _process(_delta):
	if player_nearby and Input.is_action_just_pressed("interact"):
		talia_dialogue.toggle_dialogue()
		talia_dialogue_toggled.emit()

func player_close(body):
	if body.name == "Player":
		player_nearby = true

func player_not_close(body):
	if body.name == "Player":
		player_nearby = false
