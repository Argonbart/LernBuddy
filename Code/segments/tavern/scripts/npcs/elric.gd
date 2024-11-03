extends Area2D

signal elric_dialogue_toggled()

@onready var elric_dialogue = $"../DialogueWindow"

var player : Node2D
var player_nearby : bool

func _ready():
	player = get_tree().get_root().get_node("Player")
	player_nearby = false
	self.connect("body_entered", player_close)
	self.connect("body_exited", player_not_close)
	self.connect("elric_dialogue_toggled", player.dialogue_toggled)
	initiate_elric_dialogue()

func initiate_elric_dialogue():
	elric_dialogue.set_npc("Elric", Color("#00ffff"))
	elric_dialogue.set_text("Ich bin Elric!")

func _process(_delta):
	if player_nearby and Input.is_action_just_pressed("interact"):
		elric_dialogue.toggle_dialogue()
		elric_dialogue_toggled.emit()

func player_close(body):
	if body.name == "Player":
		player_nearby = true

func player_not_close(body):
	if body.name == "Player":
		player_nearby = false
