extends CharacterBody2D

signal dialogue_started()

@onready var blacksmith_sprite = $BlacksmithSprite
@onready var blacksmith_dialogue = $Blacksmith_Dialogue

func _process(_delta):
	blacksmith_sprite.play("idle")
	
	if Input.is_action_just_pressed("chat"):
		dialogue_started.emit()
		blacksmith_dialogue.start()
