class_name MenuImplementacion
extends CanvasLayer
## Panel que explica la implementación mientras corre el laboratorio.
## M abre y cierra; 1 a 5 cambian de página. Las páginas 2 a 5 leen datos reales.

const TITULOS: Array[String] = [
	"Cuatro tipos de cuerpo",
	"Círculo contra caja (en vivo)",
	"Grupos con DFS (en vivo)",
	"Capas y máscaras (reales)",
	"Pruebas en vivo",
]
const C_FONDO: Color = Color("161240")
const C_BORDE: Color = Color("fff3d6")
const C_ROSA: Color = Color("ff5fa2")
const C_TEXTO: Color = Color("f7f2ff")

var _pagina: int = 0
var _ultimo: String = ""
var _reloj: float = 0.0
var _panel: PanelContainer
var _titulo: Label
var _cuerpo: RichTextLabel
var _lab: Laboratorio


func _ready() -> void:
	layer = 20
	_lab = get_parent() as Laboratorio
	_construir()
	_panel.visible = false


func _construir() -> void:
	_panel = PanelContainer.new()
	_panel.position = Vector2(770.0, 20.0)
	_panel.custom_minimum_size = Vector2(490.0, 680.0)
	var estilo: StyleBoxFlat = StyleBoxFlat.new()
	estilo.bg_color = Color(C_FONDO, 0.95)
	estilo.border_color = C_BORDE
	estilo.set_border_width_all(4)
	estilo.set_content_margin_all(16)
	_panel.add_theme_stylebox_override("panel", estilo)
	add_child(_panel)

	var caja: VBoxContainer = VBoxContainer.new()
	caja.add_theme_constant_override("separation", 10)
	_panel.add_child(caja)

	_titulo = Label.new()
	_titulo.add_theme_font_size_override("font_size", 25)
	_titulo.add_theme_color_override("font_color", C_ROSA)
	_titulo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	caja.add_child(_titulo)

	var linea: ColorRect = ColorRect.new()
	linea.color = C_ROSA
	linea.custom_minimum_size = Vector2(0.0, 4.0)
	caja.add_child(linea)

	_cuerpo = RichTextLabel.new()
	_cuerpo.bbcode_enabled = true
	_cuerpo.scroll_active = false
	_cuerpo.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_cuerpo.add_theme_font_size_override("normal_font_size", 20)
	_cuerpo.add_theme_font_size_override("bold_font_size", 20)
	_cuerpo.add_theme_color_override("default_color", C_TEXTO)
	caja.add_child(_cuerpo)

	var pie: Label = Label.new()
	pie.text = "M cerrar   ·   1 a 5 cambian de página"
	pie.add_theme_font_size_override("font_size", 16)
	pie.add_theme_color_override("font_color", Color("b9b2e8"))
	caja.add_child(pie)


func _unhandled_input(evento: InputEvent) -> void:
	var tecla: InputEventKey = evento as InputEventKey
	if tecla == null or not tecla.pressed or tecla.echo:
		return
	if tecla.physical_keycode == KEY_M:
		_alternar()
		get_viewport().set_input_as_handled()
	elif _panel.visible:
		if tecla.physical_keycode >= KEY_1 and tecla.physical_keycode <= KEY_5:
			_pagina = tecla.physical_keycode - KEY_1
			_actualizar()
			get_viewport().set_input_as_handled()
		elif tecla.physical_keycode == KEY_ESCAPE:
			_alternar()
			get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	if not _panel.visible:
		return
	_reloj += delta
	if _reloj >= 0.1:
		_reloj = 0.0
		_actualizar()


func _alternar() -> void:
	_panel.visible = not _panel.visible
	if _panel.visible:
		_actualizar()


func ir_a_pagina(numero: int) -> void:
	_pagina = clampi(numero, 0, TITULOS.size() - 1)
	_actualizar()


func texto_pagina(numero: int) -> String:
	match numero:
		0:
			return _pagina_cuerpos()
		1:
			return _pagina_circulo_caja()
		2:
			return _pagina_grupos()
		3:
			return _pagina_capas()
		_:
			return _pagina_pruebas()


func _actualizar() -> void:
	_titulo.text = "%d / %d  ·  %s" % [_pagina + 1, TITULOS.size(), TITULOS[_pagina]]
	var texto: String = texto_pagina(_pagina)
	if texto != _ultimo:
		_ultimo = texto
		_cuerpo.text = texto


func _jugador() -> Jugador:
	return get_tree().get_first_node_in_group("jugador") as Jugador


func _pagina_cuerpos() -> String:
	var pelotas: int = get_tree().get_nodes_in_group("pelotas").size()
	var monedas: int = _lab.get_node("Monedas").get_child_count()
	return (
		"[color=#4da3ff][b]■ Jugador[/b][/color]  CharacterBody2D\n"
		+ "   Lo mueves tú. Se desliza con move_and_slide.\n\n"
		+ "[color=#ffb84d][b]● Pelotas[/b][/color]  RigidBody2D\n"
		+ "   Las mueve el motor: rebotan. Ahora hay %d.\n\n" % pelotas
		+ "[color=#ffd93d][b]● Monedas[/b][/color]  Area2D\n"
		+ "   Detecta, no bloquea. Quedan %d.\n\n" % monedas
		+ "[color=#8b98c4][b]▲ Obstáculo y paredes[/b][/color]  StaticBody2D\n"
		+ "   Fijos: participan en la detección y nadie los mueve.\n\n"
		+ "[color=#ff5fa2]Detección[/color]: el motor avisa que hubo contacto.\n"
		+ "[color=#ff5fa2]Respuesta[/color]: qué pasa después (se desliza, rebota, desaparece)."
	)


func _pagina_circulo_caja() -> String:
	var pelotas: Array = get_tree().get_nodes_in_group("pelotas")
	var jugador: Jugador = _jugador()
	if pelotas.is_empty() or jugador == null:
		return "Faltan la pelota o el jugador."
	var pelota: Pelota = pelotas[0]
	var caja: Rect2 = jugador.caja_global()
	var radio: float = pelota.radio + Laboratorio.MARGEN_CONTACTO
	var centro: Vector2 = pelota.global_position
	var punto: Vector2 = Vector2(
		clampf(centro.x, caja.position.x, caja.end.x),
		clampf(centro.y, caja.position.y, caja.end.y)
	)
	var d: float = centro.distance_to(punto)
	var r: Dictionary = ColisionManual.circulo_aabb(centro, radio, caja)
	var choca: bool = not r.is_empty()
	var motor: bool = pelota.get_colliding_bodies().has(jugador)
	var veredicto: String = "[color=#ff5a5f][b]SEPARADOS[/b][/color]"
	var detalle: String = "   Hay %.0f px de hueco." % maxf(d - radio, 0.0)
	if choca:
		var normal: Vector2 = r["normal"]
		veredicto = "[color=#a6e36e][b]CHOCAN[/b][/color]"
		detalle = "   normal (%.2f, %.2f)   profundidad %.1f" % [normal.x, normal.y, r["profundidad"]]
	return (
		"[b]Pelota 1 contra la caja del jugador[/b]\n\n"
		+ "[color=#ff5fa2][b]1  Recortar (clamp)[/b][/color]\n"
		+ "   P = (%.0f, %.0f)\n\n" % [punto.x, punto.y]
		+ "[color=#ff5fa2][b]2  Medir[/b][/color]\n"
		+ "   d = %.1f\n\n" % d
		+ "[color=#ff5fa2][b]3  Comparar[/b][/color]\n"
		+ "   d² = %.0f   r² = %.0f\n" % [d * d, radio * radio]
		+ "   (r = radio %.0f + margen %.0f)\n\n" % [pelota.radio, Laboratorio.MARGEN_CONTACTO]
		+ "%s\n%s\n\n" % [veredicto, detalle]
		+ "Prueba manual: [b]%s[/b]   Motor: [b]%s[/b]" % [_si_no(choca), _si_no(motor)]
	)


func _pagina_grupos() -> String:
	var cuerpos: Array = [_jugador()]
	cuerpos.append_array(get_tree().get_nodes_in_group("pelotas"))
	var lineas: String = ""
	for cuerpo: Node in cuerpos:
		var nombres: PackedStringArray = PackedStringArray()
		for vecino: Node in _lab.contactos_de(cuerpo):
			nombres.append(String(vecino.name))
		var toca: String = "nadie"
		if not nombres.is_empty():
			toca = ", ".join(nombres)
		lineas += "   %s toca a: %s\n" % [cuerpo.name, toca]
	return (
		"[b]Cada cuerpo es un vértice[/b]\n"
		+ "[b]y cada contacto es una arista.[/b]\n\n"
		+ "[color=#ff5fa2][b]Contactos ahora[/b][/color]\n%s\n" % lineas
		+ "El DFS usa una pila y un conjunto de visitados. Cada vez que arranca desde un cuerpo sin visitar, cuenta un grupo.\n\n"
		+ "[color=#ffc857][b]Grupos = %d[/b][/color]\n" % _lab.grupos()
		+ "Si dos cuerpos se tocan, hay un grupo menos."
	)


func _pagina_capas() -> String:
	var jugador: Node = _jugador()
	var pelotas: Array = get_tree().get_nodes_in_group("pelotas")
	var monedas: Node = _lab.get_node("Monedas")
	var filas: Array = [["Jugador", jugador], ["Paredes", _lab.get_node("Paredes")], ["Obstáculo", _lab.get_node("Obstaculo")]]
	if not pelotas.is_empty():
		filas.insert(1, ["Pelotas", pelotas[0]])
	if monedas.get_child_count() > 0:
		filas.insert(2, ["Monedas", monedas.get_child(0)])
	var texto: String = "[b]Valores leídos del proyecto[/b]\n\n"
	for fila: Array in filas:
		var nodo: CollisionObject2D = fila[1] as CollisionObject2D
		if nodo == null:
			continue
		texto += "[color=#4fd8ff][b]%s[/b][/color]\n" % fila[0]
		texto += "   está en: %s (%d)\n" % [_nombres_bits(nodo.collision_layer), nodo.collision_layer]
		if nodo is StaticBody2D:
			texto += "   fijo: no escanea a nadie\n"
		else:
			texto += "   mira a: %s (máscara %d)\n" % [_nombres_bits(nodo.collision_mask), nodo.collision_mask]
	texto += "\nCapa = en qué grupo estoy. Máscara = a qué grupos miro. Si ninguna de las dos mira a la otra, el par ni se prueba."
	return texto


func _pagina_pruebas() -> String:
	var rombo_a: PackedVector2Array = _rombo(Vector2.ZERO, 10.0)
	var rombo_b: PackedVector2Array = _rombo(Vector2(15.0, 0.0), 10.0)
	var caja: Rect2 = Rect2(-10.0, -10.0, 20.0, 20.0)
	var casos: Array = [
		["Círculo-círculo", ColisionManual.circulo_circulo(Vector2.ZERO, 10.0, Vector2(15.0, 0.0), 10.0), 5.0],
		["AABB-AABB", ColisionManual.aabb_aabb(caja, Rect2(5.0, -5.0, 20.0, 20.0)), 5.0],
		["Círculo-AABB", ColisionManual.circulo_aabb(Vector2(17.0, 0.0), 8.0, caja), 1.0],
		["SAT (rombos)", ColisionManual.sat_poligonos(rombo_a, rombo_b), 3.5355],
	]
	var texto: String = "[b]Casos de prueba calculados ahora, con las mismas funciones[/b]\n\n"
	for caso: Array in casos:
		var resultado: Dictionary = caso[1]
		var obtenido: float = -1.0
		if not resultado.is_empty():
			obtenido = resultado["profundidad"]
		var bien: bool = absf(obtenido - float(caso[2])) < 0.001
		var marca: String = "[color=#a6e36e]✓[/color]" if bien else "[color=#ff5a5f]✗[/color]"
		texto += "%s  %s\n     profundidad %.4f   esperada %s\n" % [marca, caso[0], obtenido, str(caso[2])]
	texto += "\nLas 17 pruebas completas se ejecutan en consola:\n[color=#ffc857]godot --headless --path . --script res://scripts/pruebas_manuales.gd[/color]"
	return texto


func _rombo(centro: Vector2, radio: float) -> PackedVector2Array:
	return PackedVector2Array([
		centro + Vector2(radio, 0.0), centro + Vector2(0.0, radio),
		centro + Vector2(-radio, 0.0), centro + Vector2(0.0, -radio)
	])


func _nombres_bits(bits: int) -> String:
	var nombres: PackedStringArray = PackedStringArray()
	for i in range(32):
		if bits & (1 << i):
			var clave: String = "layer_names/2d_physics/layer_%d" % (i + 1)
			if ProjectSettings.has_setting(clave) and String(ProjectSettings.get_setting(clave)) != "":
				nombres.append(String(ProjectSettings.get_setting(clave)))
			else:
				nombres.append("capa %d" % (i + 1))
	if nombres.is_empty():
		return "nada"
	return " + ".join(nombres)


func _si_no(valor: bool) -> String:
	return "sí" if valor else "no"
