extends TextureButton

func _draw():
	var new_array : PackedVector2Array = [Vector2(0, 0), Vector2(331,0), Vector2(331, 288), Vector2(0, 288), Vector2(0, 0)]
	draw_polyline(new_array, Color.BLACK, 5.0, true)
