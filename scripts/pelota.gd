class_name Pelota
extends RigidBody2D
## RigidBody2D: el motor calcula el rebote (PhysicsMaterial: bounce 1, friction 0).

signal rebote(pelota: Pelota, con: Node)

@export var velocidad_inicial: Vector2 = Vector2(260.0, 180.0)

var radio: float = 20.0

var _destello: float = 0.0

@onready var _forma: CollisionShape2D = $Forma


func _ready() -> void:
	radio = (_forma.shape as CircleShape2D).radius
	linear_velocity = velocidad_inicial
	# Requiere contact_monitor activado en pelota.tscn
	body_entered.connect(_al_chocar)


func _process(delta: float) -> void:
	if _destello > 0.0:
		_destello = maxf(0.0, _destello - delta)
		queue_redraw()


func _al_chocar(cuerpo: Node) -> void:
	_destello = 0.15
	rebote.emit(self, cuerpo)
	queue_redraw()


func _draw() -> void:
	var color: Color = Color("ffb84d")
	if _destello > 0.0:
		color = Color("ffffff")
	draw_circle(Vector2.ZERO, radio, color)
	draw_arc(Vector2.ZERO, radio, 0.0, TAU, 32, Color("7a4b00"), 2.0)
