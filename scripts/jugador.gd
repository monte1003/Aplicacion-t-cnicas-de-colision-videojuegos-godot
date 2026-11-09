class_name Jugador
extends CharacterBody2D
## CharacterBody2D: sin física propia, el movimiento y la respuesta se programan.

## Se emite una vez al empezar a tocar otro cuerpo
signal choque(con: Node, normal: Vector2)

@export var velocidad: float = 320.0

var lado: float = 40.0

var _tocando: bool = false
var _tocaba_antes: bool = false

@onready var _forma: CollisionShape2D = $Forma


func _ready() -> void:
	lado = (_forma.shape as RectangleShape2D).size.x


func _physics_process(_delta: float) -> void:
	var direccion: Vector2 = Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)
	var d_tecla: float = float(Input.is_physical_key_pressed(KEY_D))
	var a_tecla: float = float(Input.is_physical_key_pressed(KEY_A))
	var s_tecla: float = float(Input.is_physical_key_pressed(KEY_S))
	var w_tecla: float = float(Input.is_physical_key_pressed(KEY_W))
	direccion += Vector2(d_tecla - a_tecla, s_tecla - w_tecla)
	direccion = direccion.limit_length(1.0)

	velocity = direccion * velocidad
	move_and_slide()

	# Respuesta: revisar con qué se chocó en este paso
	_tocando = get_slide_collision_count() > 0
	if _tocando and not _tocaba_antes:
		var info: KinematicCollision2D = get_slide_collision(0)
		choque.emit(info.get_collider(), info.get_normal())
	_tocaba_antes = _tocando
	queue_redraw()


func caja_global() -> Rect2:
	var mitad: Vector2 = Vector2(lado, lado) / 2.0
	return Rect2(global_position - mitad, Vector2(lado, lado))


func _draw() -> void:
	var color: Color = Color("4da3ff")
	if _tocando:
		color = Color("ff5a5f")
	var mitad: Vector2 = Vector2(lado, lado) / 2.0
	draw_rect(Rect2(-mitad, Vector2(lado, lado)), color)
	draw_rect(Rect2(-mitad, Vector2(lado, lado)), Color.WHITE, false, 2.0)
