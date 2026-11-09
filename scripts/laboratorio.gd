class_name Laboratorio
extends Node2D
## Escena principal: cuenta eventos, dibuja AABB, agrupa contactos (DFS)
## y compara la prueba manual círculo-AABB con el motor.

# El motor separa los cuerpos, así que se suma un margen al radio
const MARGEN_CONTACTO: float = 2.0

var _choques_jugador: int = 0
var _rebotes: int = 0
var _monedas_recogidas: int = 0
var _monedas_total: int = 0
var _mostrar_aabb: bool = true
var _grupos: int = 0
var _manual_pelota1: bool = false
var _motor_pelota1: bool = false

@onready var _jugador: Jugador = $Jugador
@onready var _texto: Label = $Interfaz/Texto


func _ready() -> void:
	_jugador.choque.connect(_al_chocar_jugador)
	for pelota: Pelota in get_tree().get_nodes_in_group("pelotas"):
		pelota.rebote.connect(_al_rebotar)
	for moneda: Moneda in $Monedas.get_children():
		moneda.recogida.connect(_al_recoger)
		_monedas_total += 1
	add_child(MenuImplementacion.new())
	_actualizar_texto()


func _unhandled_input(evento: InputEvent) -> void:
	if evento.is_action_pressed("ui_accept"):
		_mostrar_aabb = not _mostrar_aabb
	elif evento.is_action_pressed("ui_cancel"):
		get_tree().reload_current_scene()


func _physics_process(_delta: float) -> void:
	_grupos = _contar_grupos()
	var pelotas: Array = get_tree().get_nodes_in_group("pelotas")
	if not pelotas.is_empty():
		var primera: Pelota = pelotas[0]
		var manual: Dictionary = ColisionManual.circulo_aabb(
			primera.global_position, primera.radio + MARGEN_CONTACTO, _jugador.caja_global()
		)
		_manual_pelota1 = not manual.is_empty()
		_motor_pelota1 = primera.get_colliding_bodies().has(_jugador)
	_actualizar_texto()


## Cuerpos en contacto con `cuerpo` (lo usa el panel de la tecla M)
func contactos_de(cuerpo: Node) -> Array:
	return _vecinos(cuerpo)


func grupos() -> int:
	return _grupos


## Vértices del grafo de contactos
func _cuerpos_del_grafo() -> Array:
	var cuerpos: Array = [_jugador]
	cuerpos.append_array(get_tree().get_nodes_in_group("pelotas"))
	return cuerpos


## Aristas: cuerpos del grafo en contacto con `cuerpo`
func _vecinos(cuerpo: Node) -> Array:
	var resultado: Array = []
	if cuerpo is RigidBody2D:
		for otro in (cuerpo as RigidBody2D).get_colliding_bodies():
			if otro is RigidBody2D or otro is Jugador:
				resultado.append(otro)
	elif cuerpo is Jugador:
		for pelota in get_tree().get_nodes_in_group("pelotas"):
			if (pelota as RigidBody2D).get_colliding_bodies().has(cuerpo):
				resultado.append(pelota)
	return resultado


## Componentes conexas con DFS (pila + visitados)
func _contar_grupos() -> int:
	var visitados: Dictionary = {}
	var grupos: int = 0
	for inicio in _cuerpos_del_grafo():
		if visitados.has(inicio):
			continue
		grupos += 1
		var pila: Array = [inicio]
		while not pila.is_empty():
			var actual: Node = pila.pop_back()
			if visitados.has(actual):
				continue
			visitados[actual] = true
			for vecino in _vecinos(actual):
				if not visitados.has(vecino):
					pila.append(vecino)
	return grupos


func _al_chocar_jugador(_con: Node, _normal: Vector2) -> void:
	_choques_jugador += 1


func _al_rebotar(_pelota: Pelota, _con: Node) -> void:
	_rebotes += 1


func _al_recoger(_moneda: Moneda) -> void:
	_monedas_recogidas += 1


func _actualizar_texto() -> void:
	var si_no_manual: String = "sí" if _manual_pelota1 else "no"
	var si_no_motor: String = "sí" if _motor_pelota1 else "no"
	_texto.text = (
		"LABORATORIO DE COLISIONES\n"
		+ "Mover: flechas o WASD  |  Espacio: ver AABB  |  M: menú  |  Esc: reiniciar\n\n"
		+ "Choques del jugador (CharacterBody2D): %d\n" % _choques_jugador
		+ "Rebotes de pelotas (RigidBody2D): %d\n" % _rebotes
		+ "Monedas recogidas (Area2D): %d de %d\n" % [_monedas_recogidas, _monedas_total]
		+ "Grupos de cuerpos en contacto (DFS): %d\n" % _grupos
		+ "Pelota 1 vs jugador -> prueba manual: %s | motor: %s" % [si_no_manual, si_no_motor]
	)


func dibujar_depuracion(lienzo: CanvasItem) -> void:
	if not _mostrar_aabb:
		return
	var caja_j: Rect2 = _jugador.caja_global()
	lienzo.draw_rect(caja_j, Color("00e5ff"), false, 2.0)
	for pelota: Pelota in get_tree().get_nodes_in_group("pelotas"):
		var mitad: Vector2 = Vector2(pelota.radio, pelota.radio)
		var caja_p: Rect2 = Rect2(pelota.global_position - mitad, mitad * 2.0)
		lienzo.draw_rect(caja_p, Color("00e5ff"), false, 2.0)
	for cuerpo in _cuerpos_del_grafo():
		for vecino in _vecinos(cuerpo):
			lienzo.draw_line(
				(cuerpo as Node2D).global_position,
				(vecino as Node2D).global_position,
				Color("ff4d9a"), 3.0
			)
