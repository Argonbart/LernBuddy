extends Camera2D

var table_game_starter : Area2D
var table_game_started : bool
var zoom_target : Vector2
var position_target : Vector2
var slerp_speed : int

func _ready():
	table_game_starter = $"../Table"
	table_game_starter.connect("table_game_started", cam_to_table)
	table_game_starter.connect("table_game_finished", cam_to_tavern)
	table_game_started = false
	slerp_speed = 10
	zoom = Vector2(1.0, 1.0)
	position = Vector2(get_viewport_rect().size / 2)
	cam_to_tavern()

func _process(delta):
	update_cam(delta)

func cam_to_table():
	zoom_target = Vector2(3.0, 3.0)
	position_target = Vector2(240, 220)

func cam_to_tavern():
	zoom_target = Vector2(1.0, 1.0)
	position_target = Vector2(get_viewport_rect().size / 2)

func update_cam(delta):
	zoom = zoom.slerp(zoom_target, slerp_speed * delta)
	position = position.slerp(position_target, slerp_speed * delta)
