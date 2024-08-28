extends CharacterBody2D

signal dialogue_started()
signal dialogue_finished()

@onready var blacksmith_sprite = $BlacksmithSprite
@onready var blacksmith_dialogue = $BlacksmithDialogue

@onready var blacksmith_dialogue_box = $BlacksmithDialogue/DialogueBox
@onready var blacksmith_dialogue_name = $BlacksmithDialogue/DialogueBox/Name
@onready var blacksmith_dialogue_text = $BlacksmithDialogue/DialogueBox/Text
@onready var blacksmith_dialogue_input = $BlacksmithDialogue/TextInput

var blacksmith_dialogue_active = false
var player_nearby = false

func _ready():
	blacksmith_dialogue_box.visible = false
	blacksmith_dialogue_input.visible = false
	GeminiAPI.connect("next_response", _api_response)

func _process(_delta):
	blacksmith_sprite.play("idle")
	
	if player_nearby and Input.is_action_just_pressed("interact"):
		dialogue_started.emit()
		blacksmith_dialogue_input.grab_focus()
		start()
	
	if blacksmith_dialogue_active and Input.is_action_just_pressed("esc"):
		blacksmith_dialogue_active = false
		blacksmith_dialogue_box.visible = false
		blacksmith_dialogue_input.visible = false
		dialogue_finished.emit()
		return

func start():
	if blacksmith_dialogue_active:
		return
	blacksmith_dialogue_active = true
	blacksmith_dialogue_box.visible = true
	blacksmith_dialogue_input.visible = true
	start_conversation()

func _input(event):
	if !blacksmith_dialogue_active:
		return
	if player_nearby and event.is_action_pressed("enter"):
		if blacksmith_dialogue_input.text != "":
			GeminiAPI.next_promt(blacksmith_dialogue_input.text, "Blacksmith")
			blacksmith_dialogue_input.clear()

func start_conversation():
	blacksmith_dialogue_name.text = "Blacksmith"
	blacksmith_dialogue_text.text = "Hi! My name is Borkir. How can i help you?"

func _api_response(message, npc):
	if npc == "Blacksmith":
		blacksmith_dialogue_name.text = "Blacksmith"
		blacksmith_dialogue_text.text = message

func _on_blacksmith_chat_area_body_entered(body):
	if body.name == "Player":
		player_nearby = true

func _on_blacksmith_chat_area_body_exited(body):
	if body.name == "Player":
		player_nearby = false
