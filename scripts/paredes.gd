extends StaticBody2D
## StaticBody2D: participa en la detección, el motor no lo mueve.


func _draw() -> void:
	for hijo in get_children():
		if hijo is CollisionShape2D:
			var caja: RectangleShape2D = (hijo as CollisionShape2D).shape as RectangleShape2D
			var esquina: Vector2 = (hijo as CollisionShape2D).position - caja.size / 2.0
			draw_rect(Rect2(esquina, caja.size), Color("2b3350"))
