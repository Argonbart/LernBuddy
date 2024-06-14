extends Control

signal next_prompt(input)
signal dialogue_finished()

@onready var dialogue_box = $DialogueBox
@onready var dialogue_name = $DialogueBox/Name
@onready var dialogue_text = $DialogueBox/Text
@onready var dialogue_input = $TextInput

var d_active = false

func _ready():
	dialogue_box.visible = false
	dialogue_input.visible = false

func _process(_delta):
	if d_active and Input.is_action_just_pressed("esc"):
		d_active = false
		dialogue_box.visible = false
		dialogue_input.visible = false
		emit_signal("dialogue_finished")
		return

func start():
	if d_active:
		return
	d_active = true
	dialogue_box.visible = true
	dialogue_input.visible = true
	start_conversation()

func _input(event):
	if !d_active:
		return
	if event.is_action_pressed("enter"):
		if dialogue_input.text != "":
			next_prompt.emit(dialogue_input.text)
			dialogue_input.clear()

func start_conversation():
	dialogue_name.text = "Blacksmith"
	dialogue_text.text = "Hi! My Name is Boruk! How can i help you?"

func _on_game_manager_next_response(message):
	dialogue_name.text = "Blacksmith"
	dialogue_text.text = message
