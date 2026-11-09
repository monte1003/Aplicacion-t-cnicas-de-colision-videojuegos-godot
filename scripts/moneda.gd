class_name Moneda
extends Area2D
## Area2D: detecta con señales, no bloquea. La máscara solo escanea la capa 2 (jugador).

signal recogida(moneda: Moneda)

var radio: float = 16.0

@onready var _forma: CollisionShape2D = $Forma


func _ready() -> void:
	radio = (_forma.shape as CircleShape2D).radius
	body_entered.connect(_al_entrar_cuerpo)


func _al_entrar_cuerpo(cuerpo: Node2D) -> void:
	if cuerpo.is_in_group("jugador"):
		recogida.emit(self)
		queue_free()


func _draw() -> void:
	draw_circle(Vector2.ZERO, radio, Color("ffd93d"))
	draw_arc(Vector2.ZERO, radio, 0.0, TAU, 32, Color("8a6d00"), 2.0)
