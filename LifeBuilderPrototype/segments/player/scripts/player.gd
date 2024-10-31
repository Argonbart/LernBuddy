extends CharacterBody2D

signal activate_player()
signal deactivate_player()

var village_camera : Camera2D
@onready var player_sprite = $PlayerSprite
@onready var speed = 200

var is_active = true
var just_respawned = false
var respawn_animation = false

func _ready():
	connect("activate_player", func(): _activate_player())
	connect("deactivate_player", func(): _deactivate_player())

func _process(_delta):
	if just_respawned:
		player_sprite.play("respawn")
		respawn_animation = true
		just_respawned = false
	
	if !respawn_animation:
		if is_active:
			if Input.is_action_pressed("right") or Input.is_action_pressed("left") or Input.is_action_pressed("up") or Input.is_action_pressed("down"):
				player_sprite.play("run")
			elif Input.is_action_pressed("space"):
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

func _on_blacksmith_dialogue_finished():
	is_active = true

func _on_phantom_dialogue_started():
	is_active = false

func _on_phantom_dialogue_finished():
	is_active = true

func _on_mayor_dialogue_started():
	is_active = false

func _on_mayor_dialogue_finished():
	is_active = true

func dialogue_toggled():
	is_active = !is_active

func _activate_player():
	process_mode = Node.PROCESS_MODE_INHERIT
	just_respawned = true

func _deactivate_player():
	process_mode = Node.PROCESS_MODE_DISABLED
	player_sprite.process_mode = Node.PROCESS_MODE_ALWAYS
	player_sprite.play("off")

func _on_player_sprite_animation_finished():
	respawn_animation = false
