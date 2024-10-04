extends Polygon2D

func _draw():
	var polygon_full = polygon.duplicate()
	polygon_full.append(Vector2(82.75, 0.0))
	draw_polyline(polygon_full, Color.BLACK, 5.0, true)
