extends Camera2D

@onready var player = $"../Player"

var table_position = Vector2(250, 220)
var table_game_started = false

var zoom_target : Vector2
var drag_start_mouse_pos = Vector2.ZERO
var drag_start_camera_pos = Vector2.ZERO
var is_dragging : bool = false
var is_active : bool = false

func _ready():
	zoom_target = zoom

func _process(delta):
	#if !table_game_started and Input.is_action_just_released("camera"):
		#if is_active:
			#is_active = !is_active
			#player.is_active = !player.is_active
		#else:
			#is_active = !is_active
			#player.is_active = !player.is_active
	if table_game_started:
		move_to_table(delta)
	else:
		#zooming(delta)
		#if is_active:
			#simple_pan(delta)
			#click_and_drag(delta)
		#else:
			#position = player.global_position
		standard_position()

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

func move_to_table(delta):
	move_to_target(table_position, delta)

func move_to_target(target, delta):
	
	if(zoom_target.x <= 2.9 or zoom_target.x >= 3.1):
		zoom_target.x *= 1.03
	if(zoom_target.y <= 2.9 or zoom_target.y >= 3.1):
		zoom_target.y *= 1.03
	zoom = zoom.slerp(zoom_target, 20 * delta)
	
	var target_vector = target - position
	var move_amount = target_vector.normalized()
	if target_vector.length() > 5:
		position = position + move_amount * (1/zoom.x) * 15

func standard_position():
	zoom = Vector2(1.0, 1.0)
	position = Vector2(get_viewport_rect().size / 2)

func _on_table_table_game_started():
	table_game_started = true
	player.is_active = false

func _on_table_table_game_exited():
	table_game_started = false
	player.is_active = true
	zoom_target = Vector2(1.0, 1.0)
