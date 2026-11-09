extends Node2D
## Capa transparente dibujada por encima de todo el escenario.
## Pide a Laboratorio que dibuje sobre ella las cajas envolventes (AABB)
## y las líneas de contacto, para que queden visibles sobre los cuerpos.


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var laboratorio: Node = get_parent()
	if laboratorio.has_method("dibujar_depuracion"):
		laboratorio.dibujar_depuracion(self)
