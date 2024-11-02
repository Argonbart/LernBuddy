extends Camera2D

signal activate_player
signal deactivate_player

@onready var player : Node2D
@export var blacksmith : Node2D
@export var phantom : Node2D
@export var mayor : Node2D

var zoom_target : Vector2
var drag_start_mouse_pos = Vector2.ZERO
var drag_start_camera_pos = Vector2.ZERO
var is_dragging : bool = false
var is_active : bool = false

var blacksmith_dialogue_active = false
var phantom_dialogue_active = false
var mayor_dialogue_active = false

func _ready():
	zoom_target = zoom
	player = get_tree().get_root().get_node("Player")
	player.village_camera = self
	connect("activate_player", func(): player._activate_player())
	connect("deactivate_player", func(): player._deactivate_player())

func _process(delta):
	if Input.is_action_just_released("camera"):
		if is_active:
			activate_player.emit()
			is_active = !is_active
		else:
			deactivate_player.emit()
			is_active = !is_active
	
	zooming(delta)
	if blacksmith_dialogue_active:
		move_to_blacksmith()
	elif phantom_dialogue_active:
		move_to_phantom()
	elif mayor_dialogue_active:
		move_to_mayor()
	else:
		if is_active:
			simple_pan(delta)
			click_and_drag(delta)
		else:
			position = player.global_position

func zooming(delta):
	if Input.is_action_just_pressed("zoom_in"):
		zoom_target *= 1.1
		
	if Input.is_action_just_pressed("zoom_out"):
		zoom_target *= 0.9
	
	zoom = zoom.slerp(zoom_target, 20 * delta)

func simple_pan(delta):
	var move_amount = Vector2.ZERO
	if Input.is_action_pressed("right"):
		move_amount.x += 1
	if Input.is_action_pressed("left"):
		move_amount.x -= 1
	if Input.is_action_pressed("up"):
		move_amount.y -= 1
	if Input.is_action_pressed("down"):
		move_amount.y += 1
	
	move_amount = move_amount.normalized()
	position += move_amount * delta * 1000 * (1/zoom.x)

func click_and_drag(_delta):
	if !is_dragging and Input.is_action_just_pressed("pan"):
		drag_start_mouse_pos = get_viewport().get_mouse_position()
		drag_start_camera_pos = position
		is_dragging = true
	
	if is_dragging and Input.is_action_just_released("pan"):
		is_dragging = false
	
	if is_dragging:
		var moveVector = get_viewport().get_mouse_position() - drag_start_mouse_pos
		position = drag_start_camera_pos - moveVector * (1/zoom.x)

func move_to_blacksmith():
	move_to_target(blacksmith.global_position)

func move_to_phantom():
	move_to_target(phantom.global_position)

func move_to_mayor():
	move_to_target(mayor.global_position)
	
func move_to_target(target):
	var target_vector = target - position
	var move_amount = target_vector.normalized()
	if target_vector.length() < 1.0:
		position = target
	else:
		position = position + move_amount * (1/zoom.x)

func _on_blacksmith_dialogue_started():
	blacksmith_dialogue_active = true
	player.is_active = false

func _on_blacksmith_dialogue_finished():
	blacksmith_dialogue_active = false
	player.is_active = true

func _on_phantom_dialogue_started():
	phantom_dialogue_active = true
	player.is_active = false

func _on_phantom_dialogue_finished():
	phantom_dialogue_active = false
	player.is_active = true

func _on_mayor_dialogue_started():
	mayor_dialogue_active = true
	player.is_active = false

func _on_mayor_dialogue_finished():
	mayor_dialogue_active = false
	player.is_active = true
