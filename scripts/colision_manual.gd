class_name ColisionManual
extends RefCounted
## Pruebas de colisión escritas a mano (fase estrecha).
##
## Godot ya detecta colisiones internamente. Estas funciones reproducen, con
## el mismo procedimiento que se explica en la exposición, las pruebas más
## simples para poder compararlas con lo que reporta el motor.
##
## Todas devuelven un Dictionary:
##   - vacío ({})                       -> NO hay colisión.
##   - {"normal": Vector2, "profundidad": float} -> SÍ hay colisión.
## La normal apunta del primer cuerpo hacia el segundo.
##
## Fuente teórica: Ericson (2004), Real-Time Collision Detection, cap. 4 y 5;
## SAT: Kansas State University (s. f.). El código es de elaboración propia
## del grupo, apoyado con asistencia de IA (ver README_Godot.md).


## Círculo contra círculo: hay colisión si |d|^2 < (ra + rb)^2.
static func circulo_circulo(ca: Vector2, ra: float, cb: Vector2, rb: float) -> Dictionary:
	var d: Vector2 = cb - ca
	var suma: float = ra + rb
	var dist2: float = d.length_squared()
	if dist2 >= suma * suma:
		return {}
	var dist: float = sqrt(dist2)
	var normal: Vector2 = Vector2.RIGHT
	if dist > 0.0:
		normal = d / dist
	return {"normal": normal, "profundidad": suma - dist}


## Caja contra caja (AABB): los intervalos deben solaparse en X y en Y.
## El eje con menor solape determina la normal y la profundidad.
static func aabb_aabb(a: Rect2, b: Rect2) -> Dictionary:
	var ox: float = minf(a.end.x, b.end.x) - maxf(a.position.x, b.position.x)
	var oy: float = minf(a.end.y, b.end.y) - maxf(a.position.y, b.position.y)
	if ox <= 0.0 or oy <= 0.0:
		return {}
	var centro_a: Vector2 = a.get_center()
	var centro_b: Vector2 = b.get_center()
	if ox < oy:
		var signo_x: float = 1.0
		if centro_b.x < centro_a.x:
			signo_x = -1.0
		return {"normal": Vector2(signo_x, 0.0), "profundidad": ox}
	var signo_y: float = 1.0
	if centro_b.y < centro_a.y:
		signo_y = -1.0
	return {"normal": Vector2(0.0, signo_y), "profundidad": oy}


## Círculo contra caja: se busca el punto P de la caja más cercano al centro
## (recorte o "clamp") y se compara la distancia con el radio.
## La normal apunta del círculo hacia la caja.
static func circulo_aabb(centro: Vector2, radio: float, caja: Rect2) -> Dictionary:
	var p: Vector2 = Vector2(
		clampf(centro.x, caja.position.x, caja.end.x),
		clampf(centro.y, caja.position.y, caja.end.y)
	)
	var d: Vector2 = centro - p
	var dist2: float = d.length_squared()
	if dist2 == 0.0:
		# El centro está dentro de la caja: se sale por la cara más cercana.
		var izq: float = centro.x - caja.position.x
		var der: float = caja.end.x - centro.x
		var arr: float = centro.y - caja.position.y
		var aba: float = caja.end.y - centro.y
		var menor: float = minf(minf(izq, der), minf(arr, aba))
		var normal: Vector2 = Vector2.DOWN
		if menor == izq:
			normal = Vector2.RIGHT
		elif menor == der:
			normal = Vector2.LEFT
		elif menor == arr:
			normal = Vector2.DOWN
		else:
			normal = Vector2.UP
		return {"normal": normal, "profundidad": menor + radio}
	if dist2 >= radio * radio:
		return {}
	var dist: float = sqrt(dist2)
	return {"normal": -d / dist, "profundidad": radio - dist}


## Teorema del eje separador (SAT) para dos polígonos convexos.
## Se prueban las normales de las aristas de ambos; si en algún eje las
## proyecciones no se solapan, no hay colisión (salida temprana).
static func sat_poligonos(va: PackedVector2Array, vb: PackedVector2Array) -> Dictionary:
	var menor: float = INF
	var eje_menor: Vector2 = Vector2.ZERO
	for poligono in [va, vb]:
		var n: int = poligono.size()
		for i in n:
			var arista: Vector2 = poligono[(i + 1) % n] - poligono[i]
			var eje: Vector2 = Vector2(-arista.y, arista.x).normalized()
			var pa: Vector2 = _proyectar(va, eje)
			var pb: Vector2 = _proyectar(vb, eje)
			var solape: float = minf(pa.y, pb.y) - maxf(pa.x, pb.x)
			if solape <= 0.0:
				return {}
			if solape < menor:
				menor = solape
				eje_menor = eje
	if (_centro(vb) - _centro(va)).dot(eje_menor) < 0.0:
		eje_menor = -eje_menor
	return {"normal": eje_menor, "profundidad": menor}


## Proyecta los vértices sobre un eje unitario. Devuelve Vector2(mínimo, máximo).
static func _proyectar(vertices: PackedVector2Array, eje: Vector2) -> Vector2:
	var minimo: float = INF
	var maximo: float = -INF
	for v in vertices:
		var valor: float = v.dot(eje)
		minimo = minf(minimo, valor)
		maximo = maxf(maximo, valor)
	return Vector2(minimo, maximo)


static func _centro(vertices: PackedVector2Array) -> Vector2:
	var suma: Vector2 = Vector2.ZERO
	for v in vertices:
		suma += v
	return suma / float(vertices.size())
