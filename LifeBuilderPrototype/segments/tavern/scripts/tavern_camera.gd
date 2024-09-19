extends Camera2D

var zoom_target : Vector2
var position_target : Vector2
var slerp_speed : int

func _ready():
	slerp_speed = 10
	zoom = Vector2(1.6, 1.6)
	position = Vector2(get_viewport_rect().size / 2)
	cam_to_tavern()

func _process(delta):
	update_cam(delta)

func cam_to_tavern():
	zoom_target = Vector2(1.6, 1.6)
	position_target = Vector2(get_viewport_rect().size / 2)

func update_cam(delta):
	zoom = zoom.slerp(zoom_target, slerp_speed * delta)
	position = position.slerp(position_target, slerp_speed * delta)
