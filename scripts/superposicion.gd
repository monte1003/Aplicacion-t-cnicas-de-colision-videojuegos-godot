extends Node2D
## Capa superior que pide a Laboratorio dibujar AABB y contactos.


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var laboratorio: Node = get_parent()
	if laboratorio.has_method("dibujar_depuracion"):
		laboratorio.dibujar_depuracion(self)
