extends CharacterBody2D

signal dialogue_started()
signal dialogue_finished()

@onready var mayor_sprite = $MayorSprite

@onready var mayor_dialogue_box = $MayorDialogue/DialogueBox
@onready var mayor_dialogue_name = $MayorDialogue/DialogueBox/Name
@onready var mayor_dialogue_text = $MayorDialogue/DialogueBox/Text
@onready var mayor_text_input = $MayorDialogue/TextInput

var mayor_dialogue_active = false
var player_nearby = false

func _ready():
	mayor_dialogue_box.visible = false
	mayor_text_input.visible = false

func _process(_delta):
	mayor_sprite.play("idle")
	
	if player_nearby and Input.is_action_just_pressed("interact"):
		dialogue_started.emit()
		start()
	
	if mayor_dialogue_active and Input.is_action_just_pressed("esc"):
		mayor_dialogue_active = false
		mayor_dialogue_box.visible = false
		dialogue_finished.emit()
		return

func start():
	if mayor_dialogue_active:
		return
	mayor_dialogue_active = true
	mayor_dialogue_box.visible = true
	start_conversation()

func start_conversation():
	mayor_dialogue_name.text = "Mayor"
	mayor_dialogue_text.text = "Hello! Try placing a building by pressing Q! I will tell you more later."

func _on_mayor_chat_area_body_entered(body):
	if body.name == "Player":
		player_nearby = true

func _on_mayor_chat_area_body_exited(body):
	if body.name == "Player":
		player_nearby = false
