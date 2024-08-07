#extends Node
#
#var scene_one = load("res://scenes/world.tscn").instance()
#var scene_two = load("res://scenes/taverne.tscn").instance()
#var current_scene = null
#
#func _ready():
	#switch_scene(scene_one)
#
#func switch_scene(new_scene):
	#if new_scene.is_inside_tree():
		#return
#
	##Add new scene below old scene to keep 
	##the same index once old_scene is removed
	#if current_scene and current_scene.is_inside_tree():
		#add_child(new_scene, current_scene)
		#remove_child(current_scene)
	#else:
		#add_child(new_scene)
	#current_scene = new_scene
