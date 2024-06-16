extends CharacterBody2D

signal dialogue_started()
signal dialogue_finished()

@onready var mayor_sprite = $MayorSprite

@onready var mayor_dialogue_box = $MayorDialogue/DialogueBox
@onready var mayor_dialogue_name = $MayorDialogue/DialogueBox/Name
@onready var mayor_dialogue_text = $MayorDialogue/DialogueBox/Text
@onready var mayor_text_input = $MayorDialogue/TextInput

@export var player_choice_dialog : Control

var mayor_dialogue_active = false
var player_nearby = false

var dialogue = []
var current_dialogue_id = 0

func _ready():
	player_choice_dialog.visible = false
	mayor_dialogue_box.visible = false
	mayor_text_input.visible = false

func _process(_delta):
	mayor_sprite.play("idle")
	
	if player_nearby and Input.is_action_just_pressed("interact"):
		dialogue_started.emit()
		start()
	
	if mayor_dialogue_active and Input.is_action_just_pressed("click"):
		next_script()
	
	if mayor_dialogue_active and Input.is_action_just_pressed("esc"):
		close_dialogue()

func start():
	if mayor_dialogue_active:
		return
	mayor_dialogue_active = true
	mayor_dialogue_box.visible = true
	
	dialogue = load_dialogue()
	current_dialogue_id = -1
	next_script()

func load_dialogue():
	var file = FileAccess.open("res://dialogue/mayor_dialogue.json", FileAccess.READ)
	var content = JSON.parse_string(file.get_as_text())
	return content

func next_script():
	current_dialogue_id += 1
	if current_dialogue_id >= len(dialogue):
		close_dialogue()
		return
	
	var next_name = dialogue[current_dialogue_id]['name']
	
	if next_name == "You":
		var options = dialogue[current_dialogue_id]['options']
		player_choice_dialog.choices = options
		player_choice_dialog.visible = true
		mayor_dialogue_box.visible = false
	else:
		var next_text = dialogue[current_dialogue_id]['text']
		mayor_dialogue_name.text = next_name
		mayor_dialogue_text.text = next_text
		player_choice_dialog.visible = false
		mayor_dialogue_box.visible = true

func close_dialogue():
	mayor_dialogue_active = false
	mayor_dialogue_box.visible = false
	dialogue_finished.emit()

func _on_mayor_chat_area_body_entered(body):
	if body.name == "Player":
		player_nearby = true

func _on_mayor_chat_area_body_exited(body):
	if body.name == "Player":
		player_nearby = false
