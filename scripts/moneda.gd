class_name Moneda
extends Area2D
## Moneda (Area2D): sirve para DETECTAR, no para bloquear.
##
## Un Area2D no choca físicamente; avisa con señales cuando un cuerpo
## entra o sale de su zona. Su collision_mask solo escanea la capa 2
## (jugador), así que las pelotas la atraviesan sin activarla.

## Se emite cuando el jugador entra en la zona de la moneda.
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
