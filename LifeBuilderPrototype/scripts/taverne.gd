extends Node

var current_scene = null

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)

func switch_scene(res_path):
	print("x")
	call_deferred("_deferred_switch_scene", res_path)
	print("y")

func _deferred_switch_scene(res_path):
	print("o")
	current_scene.free()
	print("a")
	var s = load(res_path)
	print("b")
	current_scene = s.instantiate()
	print("c", current_scene)
	get_tree().root.add_child(current_scene)
	print("d")
	get_tree().current_scene = current_scene
	print("e")

var player_nearby = false

func _process(_delta):
	if player_nearby and Input.is_action_just_pressed("interact"):
		print("c")
		switch_scene("res://scenes/taverne.tscn")
		#get_tree().change_scene_to_file("res://scenes/taverne.tscn")

func _on_taverne_entry_body_entered(body):
	if body.name == "Player":
		player_nearby = true

func _on_taverne_entry_body_exited(body):
	if body.name == "Player":
		player_nearby = false
