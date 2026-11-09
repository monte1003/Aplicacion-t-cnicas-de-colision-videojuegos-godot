extends SceneTree
## Pruebas de ColisionManual. Ejecutar: godot --headless --path . --script res://scripts/pruebas_manuales.gd

const Manual := preload("res://scripts/colision_manual.gd")

var _total: int = 0
var _fallos: int = 0


func _init() -> void:
	var caja_a: Rect2 = Rect2(-10, -10, 20, 20)

	var r1: Dictionary = Manual.circulo_circulo(Vector2(0, 0), 10.0, Vector2(15, 0), 10.0)
	_verificar("circulo-circulo: chocan", not r1.is_empty())
	_verificar("circulo-circulo: profundidad 5", _cerca(r1.get("profundidad", -1.0), 5.0))
	_verificar(
		"circulo-circulo: normal (1,0)", _cerca_v(r1.get("normal", Vector2.ZERO), Vector2.RIGHT)
	)
	var r2: Dictionary = Manual.circulo_circulo(Vector2(0, 0), 10.0, Vector2(25, 0), 10.0)
	_verificar("circulo-circulo: separados", r2.is_empty())

	var r3: Dictionary = Manual.aabb_aabb(caja_a, Rect2(5, -5, 20, 20))
	_verificar("aabb-aabb: profundidad 5", _cerca(r3.get("profundidad", -1.0), 5.0))
	_verificar("aabb-aabb: normal (1,0)", _cerca_v(r3.get("normal", Vector2.ZERO), Vector2(1, 0)))
	var r4: Dictionary = Manual.aabb_aabb(caja_a, Rect2(20, -10, 20, 20))
	_verificar("aabb-aabb: separadas", r4.is_empty())

	var r5: Dictionary = Manual.circulo_aabb(Vector2(17, 0), 8.0, caja_a)
	_verificar("circulo-aabb: profundidad 1", _cerca(r5.get("profundidad", -1.0), 1.0))
	_verificar("circulo-aabb: normal (-1,0)", _cerca_v(r5.get("normal", Vector2.ZERO), Vector2(-1, 0)))
	var r6: Dictionary = Manual.circulo_aabb(Vector2(5, 0), 8.0, caja_a)
	_verificar("circulo-aabb: dentro, prof. 13", _cerca(r6.get("profundidad", -1.0), 13.0))
	_verificar(
		"circulo-aabb: dentro, normal (-1,0)",
		_cerca_v(r6.get("normal", Vector2.ZERO), Vector2.LEFT)
	)
	var r7: Dictionary = Manual.circulo_aabb(Vector2(30, 0), 8.0, caja_a)
	_verificar("circulo-aabb: separados", r7.is_empty())

	var rombo_a: PackedVector2Array = _rombo(Vector2(0, 0), 10.0)
	var r8: Dictionary = Manual.sat_poligonos(rombo_a, _rombo(Vector2(15, 0), 10.0))
	_verificar("sat rombos: profundidad 3.5355", _cerca(r8.get("profundidad", -1.0), 3.5355))
	var n8: Vector2 = r8.get("normal", Vector2.ZERO)
	_verificar("sat rombos: normal diagonal hacia +x", _cerca(absf(n8.x), 0.70711) and n8.x > 0.0)
	var r9: Dictionary = Manual.sat_poligonos(rombo_a, _rombo(Vector2(25, 0), 10.0))
	_verificar("sat rombos: separados", r9.is_empty())

	var cuadrado_a: PackedVector2Array = PackedVector2Array(
		[Vector2(-10, -10), Vector2(10, -10), Vector2(10, 10), Vector2(-10, 10)]
	)
	var cuadrado_b: PackedVector2Array = PackedVector2Array(
		[Vector2(5, -5), Vector2(25, -5), Vector2(25, 15), Vector2(5, 15)]
	)
	var r10: Dictionary = Manual.sat_poligonos(cuadrado_a, cuadrado_b)
	_verificar("sat cuadrados: profundidad 5", _cerca(r10.get("profundidad", -1.0), 5.0))
	_verificar("sat cuadrados: normal (1,0)", _cerca_v(r10.get("normal", Vector2.ZERO), Vector2(1, 0)))

	print("Pruebas: %d | fallos: %d" % [_total, _fallos])
	quit(1 if _fallos > 0 else 0)


func _rombo(centro: Vector2, radio: float) -> PackedVector2Array:
	return PackedVector2Array([
		centro + Vector2(radio, 0), centro + Vector2(0, radio),
		centro + Vector2(-radio, 0), centro + Vector2(0, -radio)
	])


func _verificar(nombre: String, condicion: bool) -> void:
	_total += 1
	if condicion:
		print("ok     " + nombre)
	else:
		_fallos += 1
		print("FALLO  " + nombre)


func _cerca(a: float, b: float) -> bool:
	return absf(a - b) < 0.001


func _cerca_v(a: Vector2, b: Vector2) -> bool:
	return a.distance_to(b) < 0.001
