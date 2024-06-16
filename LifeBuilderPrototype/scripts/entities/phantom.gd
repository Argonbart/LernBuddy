extends CharacterBody2D

signal dialogue_started()
signal dialogue_finished()
signal next_prompt(input)

@onready var phantom_sprite = $PhantomSprite

@onready var phantom_dialogue_box = $PhantomDialogue/DialogueBox
@onready var phantom_dialogue_name = $PhantomDialogue/DialogueBox/Name
@onready var phantom_dialogue_text = $PhantomDialogue/DialogueBox/Text
@onready var phantom_dialogue_input = $PhantomDialogue/TextInput

var phantom_dialogue_active = false
var player_nearby = false

func _ready():
	phantom_dialogue_box.visible = false
	phantom_dialogue_input.visible = false

func _process(_delta):
	phantom_sprite.play("idle")
	
	if player_nearby and Input.is_action_just_pressed("interact"):
		dialogue_started.emit()
		phantom_dialogue_input.grab_focus()
		start()
	
	if phantom_dialogue_active and Input.is_action_just_pressed("esc"):
		phantom_dialogue_active = false
		phantom_dialogue_box.visible = false
		phantom_dialogue_input.visible = false
		dialogue_finished.emit()
		return

func start():
	if phantom_dialogue_active:
		return
	phantom_dialogue_active = true
	phantom_dialogue_box.visible = true
	phantom_dialogue_input.visible = true
	start_conversation()

func _input(event):
	if !phantom_dialogue_active:
		return
	if player_nearby and event.is_action_pressed("enter"):
		if phantom_dialogue_input.text != "":
			next_prompt.emit(phantom_dialogue_input.text)
			phantom_dialogue_input.clear()

func start_conversation():
	phantom_dialogue_name.text = "Phantom"
	phantom_dialogue_text.text = "Sha-Aksh!"

func _on_chat_api_next_response(message, npc_id):
	if npc_id == 1:
		phantom_dialogue_name.text = "Phantom"
		phantom_dialogue_text.text = message

func _on_phantom_chat_area_body_entered(body):
	if body.name == "Player":
		player_nearby = true

func _on_phantom_chat_area_body_exited(body):
	if body.name == "Player":
		player_nearby = false
