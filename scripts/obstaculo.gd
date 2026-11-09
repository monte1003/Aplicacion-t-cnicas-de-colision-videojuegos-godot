extends StaticBody2D
## Obstáculo triangular (StaticBody2D con CollisionPolygon2D).
##
## Es un polígono convexo y está rotado: por eso su caja envolvente (AABB)
## es mayor que la forma real, y el motor necesita una prueba de fase estrecha
## precisa (el motor usa SAT para estas formas).

@onready var _forma: CollisionPolygon2D = $Forma


func _draw() -> void:
	draw_colored_polygon(_forma.polygon, Color("5b6b8c"))
	var contorno: PackedVector2Array = _forma.polygon
	contorno.append(contorno[0])
	draw_polyline(contorno, Color.WHITE, 2.0)
