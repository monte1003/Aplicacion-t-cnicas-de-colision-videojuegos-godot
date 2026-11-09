extends StaticBody2D
## Polígono convexo rotado: su AABB es mayor que la forma real (el motor usa SAT).

@onready var _forma: CollisionPolygon2D = $Forma


func _draw() -> void:
	draw_colored_polygon(_forma.polygon, Color("5b6b8c"))
	var contorno: PackedVector2Array = _forma.polygon
	contorno.append(contorno[0])
	draw_polyline(contorno, Color.WHITE, 2.0)
