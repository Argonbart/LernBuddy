extends Camera2D

var zoom_target : Vector2
var is_dragging : bool = false
var drag_start_mouse_pos = Vector2.ZERO
var drag_start_camera_pos = Vector2.ZERO

func _ready():
	zoom_target = zoom

func _process(delta):
	zooming(delta)
	simple_pan(delta)
	click_and_drag(delta)

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
