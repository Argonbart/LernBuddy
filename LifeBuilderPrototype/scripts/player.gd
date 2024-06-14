extends CharacterBody2D

@onready var player_sprite = $PlayerSprite
@onready var speed = 100

var is_active = true

func _process(_delta):
	if is_active:
		if Input.is_action_pressed("right") or Input.is_action_pressed("left"):
			player_sprite.play("run")
		elif Input.is_action_pressed("jump"):
			player_sprite.play("jump")
		else:
			player_sprite.play("idle")
	else:
		player_sprite.play("idle")

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed

func _physics_process(_delta):
	if is_active:
		get_input()
		var horizontal_direction = Input.get_axis("left", "right")
		if horizontal_direction != 0:
			player_sprite.flip_h = (horizontal_direction == -1)
		move_and_slide()

func _on_blacksmith_dialogue_started():
	is_active = false

func _on_blacksmith_dialogue_dialogue_finished():
	is_active = true
