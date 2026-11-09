class_name Pelota
extends RigidBody2D
## Pelota con física (RigidBody2D).
##
## Un RigidBody2D SÍ tiene física: no se mueve con código, el motor calcula
## la respuesta (rebote). Aquí solo se le da una velocidad inicial y se
## escucha la señal body_entered para contar los rebotes.
## El rebote lo define el PhysicsMaterial (bounce = 1.0, friction = 0.0).

## Se emite cuando la pelota choca contra otro cuerpo.
signal rebote(pelota: Pelota, con: Node)

@export var velocidad_inicial: Vector2 = Vector2(260.0, 180.0)

var radio: float = 20.0

var _destello: float = 0.0

@onready var _forma: CollisionShape2D = $Forma


func _ready() -> void:
	radio = (_forma.shape as CircleShape2D).radius
	linear_velocity = velocidad_inicial
	# contact_monitor y max_contacts_reported están activados en pelota.tscn;
	# sin ellos el RigidBody2D no emite body_entered.
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
