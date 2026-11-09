extends Control
## Pantalla de inicio: elegir un nivel abre el laboratorio con el panel (tecla M) en esa página.

const LABORATORIO: String = "res://escenas/laboratorio.tscn"
const C_FONDO: Color = Color("161240")
const C_CREMA: Color = Color("fff3d6")
const C_ROSA: Color = Color("ff5fa2")
const C_AMARILLO: Color = Color("ffc857")
const C_VERDE: Color = Color("a6e36e")
const C_TEXTO: Color = Color("f7f2ff")
const C_SUAVE: Color = Color("b9b2e8")
const ANCHO_FICHA: float = 190.0
const ALTO_FICHA: float = 170.0

const NIVELES: Array = [
	{"titulo": "El laboratorio", "archivo": "laboratorio.gd", "color": Color("ff5fa2")},
	{"titulo": "Círculo contra caja", "archivo": "colision_manual.gd", "color": Color("ffb84d")},
	{"titulo": "El eje separador", "archivo": "sat_poligonos()", "color": Color("4da3ff")},
	{"titulo": "Grupos con DFS", "archivo": "_contar_grupos()", "color": Color("a6e36e")},
	{"titulo": "Capas y máscaras", "archivo": "project.godot", "color": Color("4fd8ff")},
	{"titulo": "17 pruebas", "archivo": "pruebas_manuales.gd", "color": Color("ffc857")},
]
## Posición de cada ficha: tres arriba y tres abajo, recorrido en zigzag.
const POSICIONES: Array[Vector2] = [
	Vector2(560.0, 112.0), Vector2(800.0, 112.0), Vector2(1040.0, 112.0),
	Vector2(1040.0, 410.0), Vector2(800.0, 410.0), Vector2(560.0, 410.0),
]

var _insignias: Array[Label] = []


func _ready() -> void:
	_construir_textos()
	for i in NIVELES.size():
		_crear_ficha(i)


func _construir_textos() -> void:
	var avatar: Label = _etiqueta("I", Vector2(36.0, 20.0), 30, C_FONDO)
	avatar.custom_minimum_size = Vector2(52.0, 52.0)
	avatar.size = Vector2(52.0, 52.0)
	avatar.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	avatar.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	avatar.add_theme_stylebox_override("normal", _caja(C_ROSA, C_CREMA, 3))
	_etiqueta("ISAAC", Vector2(100.0, 16.0), 15, C_TEXTO)
	_etiqueta("ESTRUCTURA DE DATOS II · IST 4031\nUNIVERSIDAD DEL NORTE · 2026-30", Vector2(380.0, 18.0), 13, C_SUAVE).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var derecha: Label = _etiqueta("MENÚ\nIMPLEMENTACIÓN", Vector2(900.0, 18.0), 13, C_SUAVE)
	derecha.size = Vector2(344.0, 40.0)
	derecha.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	var fuente: FontVariation = FontVariation.new()
	fuente.base_font = ThemeDB.fallback_font
	fuente.variation_embolden = 0.9
	var titulo: Label = _etiqueta("Implementación\nen Godot", Vector2(40.0, 104.0), 56, C_TEXTO)
	titulo.add_theme_font_override("font", fuente)
	titulo.add_theme_constant_override("line_spacing", -4)

	var sub: Label = _etiqueta("Un laboratorio de colisiones con seis niveles. Elige uno para ver qué pasa dentro del código.", Vector2(44.0, 304.0), 24, C_SUAVE)
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sub.custom_minimum_size = Vector2(440.0, 0.0)
	sub.size = Vector2(440.0, 120.0)

	var empezar: Button = Button.new()
	empezar.text = "▶  EMPEZAR"
	empezar.position = Vector2(44.0, 450.0)
	empezar.custom_minimum_size = Vector2(210.0, 54.0)
	empezar.focus_mode = Control.FOCUS_NONE
	empezar.add_theme_font_size_override("font_size", 22)
	empezar.add_theme_color_override("font_color", C_FONDO)
	empezar.add_theme_color_override("font_hover_color", C_FONDO)
	empezar.add_theme_color_override("font_pressed_color", C_FONDO)
	empezar.add_theme_stylebox_override("normal", _caja(C_ROSA, C_CREMA, 3))
	empezar.add_theme_stylebox_override("hover", _caja(C_ROSA.lightened(0.2), C_AMARILLO, 3))
	empezar.add_theme_stylebox_override("pressed", _caja(C_ROSA.darkened(0.15), C_CREMA, 3))
	empezar.pressed.connect(_abrir.bind(1))
	add_child(empezar)

	_etiqueta("TECLAS 1 A 6 ABREN UN NIVEL  ·  ENTER EMPIEZA  ·  EN EL LABORATORIO: M PANEL, I INICIO  ·  F PANTALLA COMPLETA", Vector2(36.0, 686.0), 13, C_SUAVE)


func _crear_ficha(indice: int) -> void:
	var nivel: Dictionary = NIVELES[indice]
	var color: Color = nivel["color"]
	var origen: Vector2 = POSICIONES[indice]

	var ficha: Button = Button.new()
	ficha.position = origen
	ficha.custom_minimum_size = Vector2(ANCHO_FICHA, ALTO_FICHA)
	ficha.size = Vector2(ANCHO_FICHA, ALTO_FICHA)
	ficha.focus_mode = Control.FOCUS_NONE
	ficha.tooltip_text = "%d. %s" % [indice + 1, nivel["titulo"]]
	ficha.add_theme_stylebox_override("normal", _caja(C_FONDO.lerp(color, 0.25), C_CREMA, 4))
	ficha.add_theme_stylebox_override("hover", _caja(C_FONDO.lerp(color, 0.45), C_AMARILLO, 4))
	ficha.add_theme_stylebox_override("pressed", _caja(C_FONDO.lerp(color, 0.35), C_AMARILLO, 4))
	ficha.pressed.connect(_abrir.bind(indice + 1))
	ficha.draw.connect(_dibujar_icono.bind(ficha, indice))
	add_child(ficha)

	var numero: Label = _etiqueta(str(indice + 1), origen + Vector2(-8.0, -10.0), 20, C_FONDO)
	numero.add_theme_stylebox_override("normal", _caja(C_AMARILLO, C_FONDO, 3))
	numero.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var visto: Label = _etiqueta("✓", origen + Vector2(ANCHO_FICHA - 30.0, -10.0), 20, C_FONDO)
	visto.add_theme_stylebox_override("normal", _caja(C_VERDE, C_FONDO, 3))
	visto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	visto.visible = _visitados().has(indice + 1)
	_insignias.append(visto)

	_etiqueta(nivel["titulo"], origen + Vector2(0.0, ALTO_FICHA + 10.0), 21, C_TEXTO)
	_etiqueta(nivel["archivo"], origen + Vector2(0.0, ALTO_FICHA + 38.0), 14, C_SUAVE)


func _etiqueta(texto: String, posicion: Vector2, tamano: int, color: Color) -> Label:
	var e: Label = Label.new()
	e.text = texto
	e.position = posicion
	e.mouse_filter = Control.MOUSE_FILTER_IGNORE
	e.add_theme_font_size_override("font_size", tamano)
	e.add_theme_color_override("font_color", color)
	add_child(e)
	return e


func _caja(relleno: Color, borde: Color, grosor: int) -> StyleBoxFlat:
	var s: StyleBoxFlat = StyleBoxFlat.new()
	s.bg_color = relleno
	s.border_color = borde
	s.set_border_width_all(grosor)
	s.set_content_margin_all(4)
	return s


func _visitados() -> Dictionary:
	if not Engine.has_meta("niveles_visitados"):
		Engine.set_meta("niveles_visitados", {})
	return Engine.get_meta("niveles_visitados")


func _abrir(nivel: int) -> void:
	_visitados()[nivel] = true
	Engine.set_meta("pagina_inicial", nivel)
	get_tree().change_scene_to_file(LABORATORIO)


func _unhandled_key_input(evento: InputEvent) -> void:
	var tecla: InputEventKey = evento as InputEventKey
	if tecla == null or not tecla.pressed or tecla.echo:
		return
	if tecla.physical_keycode >= KEY_1 and tecla.physical_keycode <= KEY_6:
		_abrir(tecla.physical_keycode - KEY_1 + 1)
	elif tecla.physical_keycode == KEY_ENTER or tecla.physical_keycode == KEY_KP_ENTER or tecla.physical_keycode == KEY_SPACE:
		_abrir(1)
	elif tecla.physical_keycode == KEY_F:
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _draw() -> void:
	var tam: Vector2 = get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, tam), C_FONDO)
	var linea: Color = Color(1.0, 1.0, 1.0, 0.035)
	var x: float = 0.0
	while x < tam.x:
		draw_line(Vector2(x, 0.0), Vector2(x, tam.y), linea, 1.0)
		x += 32.0
	var y: float = 0.0
	while y < tam.y:
		draw_line(Vector2(0.0, y), Vector2(tam.x, y), linea, 1.0)
		y += 32.0
	# barra de progreso: un segmento de 24 por cada sexto de niveles vistos
	var activos: int = roundi(_visitados().size() / 6.0 * 24.0)
	for i in 24:
		var c: Color = C_ROSA if i < activos else Color("3a3392")
		draw_rect(Rect2(100.0 + i * 9.0, 42.0, 6.0, 16.0), c)
	# camino punteado entre fichas
	var mitad: Vector2 = Vector2(ANCHO_FICHA, ALTO_FICHA) / 2.0
	var punteado: Color = Color("5149b8")
	for par: Array in [[0, 1], [1, 2], [2, 3], [3, 4], [4, 5]]:
		var a: Vector2 = POSICIONES[par[0]] + mitad
		var b: Vector2 = POSICIONES[par[1]] + mitad
		var dir: Vector2 = (b - a).normalized()
		var largo: float = a.distance_to(b) - ANCHO_FICHA if absf(dir.x) > 0.5 else a.distance_to(b) - ALTO_FICHA
		var inicio: Vector2 = a + dir * (ANCHO_FICHA / 2.0 if absf(dir.x) > 0.5 else ALTO_FICHA / 2.0)
		var d: float = 8.0
		while d < largo - 4.0:
			draw_rect(Rect2(inicio + dir * d - Vector2(3.0, 3.0), Vector2(6.0, 6.0)), punteado)
			d += 14.0


func _dibujar_icono(ficha: Control, indice: int) -> void:
	var c: Vector2 = ficha.size / 2.0
	var crema: Color = C_CREMA
	match indice:
		0:
			ficha.draw_rect(Rect2(c + Vector2(-52.0, -44.0), Vector2(104.0, 88.0)), crema, false, 5.0)
			ficha.draw_circle(c + Vector2(22.0, -18.0), 11.0, Color("ffb84d"))
			ficha.draw_rect(Rect2(c + Vector2(-36.0, 0.0), Vector2(22.0, 22.0)), Color("4da3ff"))
			ficha.draw_circle(c + Vector2(2.0, 20.0), 7.0, Color("ffd93d"))
			ficha.draw_colored_polygon(PackedVector2Array([c + Vector2(22.0, 28.0), c + Vector2(44.0, 28.0), c + Vector2(33.0, 6.0)]), Color("8b98c4"))
		1:
			ficha.draw_rect(Rect2(c + Vector2(4.0, -34.0), Vector2(54.0, 68.0)), Color("4da3ff"), false, 5.0)
			ficha.draw_circle(c + Vector2(-12.0, 0.0), 32.0, Color("ffb84dd9"))
			ficha.draw_arc(c + Vector2(-12.0, 0.0), 32.0, 0.0, TAU, 32, Color("7a4b00"), 4.0)
			ficha.draw_colored_polygon(PackedVector2Array([c + Vector2(4.0, -9.0), c + Vector2(13.0, 0.0), c + Vector2(4.0, 9.0), c + Vector2(-5.0, 0.0)]), C_ROSA)
		2:
			ficha.draw_colored_polygon(PackedVector2Array([c + Vector2(-20.0, -50.0), c + Vector2(10.0, -20.0), c + Vector2(-20.0, 10.0), c + Vector2(-50.0, -20.0)]), Color("4da3ffcc"))
			ficha.draw_colored_polygon(PackedVector2Array([c + Vector2(24.0, -22.0), c + Vector2(54.0, 8.0), c + Vector2(24.0, 38.0), c + Vector2(-6.0, 8.0)]), Color("ff5fa2cc"))
			ficha.draw_line(c + Vector2(-50.0, 48.0), c + Vector2(54.0, -46.0), C_AMARILLO, 5.0)
		3:
			ficha.draw_line(c + Vector2(-30.0, -24.0), c + Vector2(26.0, -30.0), C_ROSA, 5.0)
			ficha.draw_line(c + Vector2(-30.0, -24.0), c + Vector2(-12.0, 32.0), C_ROSA, 5.0)
			ficha.draw_circle(c + Vector2(-30.0, -24.0), 15.0, Color("4da3ff"))
			ficha.draw_circle(c + Vector2(26.0, -30.0), 15.0, Color("a6e36e"))
			ficha.draw_circle(c + Vector2(-12.0, 32.0), 15.0, Color("a6e36e"))
			ficha.draw_circle(c + Vector2(40.0, 30.0), 11.0, Color("ffb84d"))
		4:
			ficha.draw_rect(Rect2(c + Vector2(-48.0, 8.0), Vector2(78.0, 28.0)), Color("2b2580"))
			ficha.draw_rect(Rect2(c + Vector2(-40.0, -14.0), Vector2(78.0, 28.0)), Color("4fd8ff"))
			ficha.draw_rect(Rect2(c + Vector2(-32.0, -36.0), Vector2(72.0, 28.0)), C_AMARILLO)
		5:
			ficha.draw_rect(Rect2(c + Vector2(-44.0, -44.0), Vector2(88.0, 88.0)), Color("0c0a26"))
			ficha.draw_rect(Rect2(c + Vector2(-44.0, -44.0), Vector2(88.0, 88.0)), crema, false, 5.0)
			ficha.draw_polyline(PackedVector2Array([c + Vector2(-26.0, 2.0), c + Vector2(-8.0, 22.0), c + Vector2(28.0, -20.0)]), C_VERDE, 9.0)
