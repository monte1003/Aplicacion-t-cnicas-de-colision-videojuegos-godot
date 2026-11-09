# Laboratorio de colisiones en Godot (Grupo 2 · IST 4031 Estructura de Datos II)

Proyecto Godot 4.7 (2D). Parte de la plantilla vacía que ya tenía la carpeta
(`project.godot`, `icon.svg`) y le agrega una escena jugable que muestra los
cuatro tipos de objetos de colisión de Godot y las pruebas de colisión explicadas
en la exposición.

## Cómo ejecutarlo

1. Abrir la carpeta con Godot 4.7 (`Importar` -> `project.godot`).
2. Esperar a que el editor termine de importar (la primera vez construye la caché de clases).
3. Pulsar **F5**. La escena principal es `escenas/laboratorio.tscn`.

Controles: flechas o WASD mueven al jugador (cuadrado azul) · **Espacio** muestra u oculta
las cajas envolventes (AABB) y las líneas de contacto · **Esc** reinicia.

Pruebas sin abrir el editor (el ejecutable puede llamarse `godot`, `godot4` o `Godot_v4.x_win64_console.exe`):

```
godot --headless --path . --script res://scripts/pruebas_manuales.gd
```

## Qué contiene

| Archivo | Nodo raíz | Función |
|---|---|---|
| `escenas/laboratorio.tscn` | Node2D | Escena principal: instancia todo lo demás y la interfaz. |
| `escenas/paredes.tscn` | StaticBody2D | Cuatro paredes (CollisionShape2D rectangulares). |
| `escenas/obstaculo.tscn` | StaticBody2D | Triángulo rotado (CollisionPolygon2D). |
| `escenas/jugador.tscn` | CharacterBody2D | Jugador; responde deslizándose. |
| `escenas/pelota.tscn` | RigidBody2D | Pelota con rebote controlado por el motor. |
| `escenas/moneda.tscn` | Area2D | Zona de detección sin bloqueo físico. |
| `scripts/colision_manual.gd` | RefCounted | Círculo-círculo, AABB-AABB, círculo-AABB y SAT escritos a mano. |
| `scripts/laboratorio.gd` | Node2D | Contadores, AABB, grafo de contactos (DFS) y comparación manual/motor. |
| `scripts/pruebas_manuales.gd` | SceneTree | 17 comprobaciones con cálculos hechos a mano. |

Capas de colisión (nombradas en `project.godot`): 1 paredes · 2 jugador · 3 pelotas · 4 monedas.

## Estado de la verificación (leer antes de exponer)

- Los scripts pasaron el análisis de sintaxis de `gdtoolkit` (gdparse y gdlint) sin errores.
- La lógica de `colision_manual.gd` se tradujo a Python y las 17 comprobaciones dieron los valores esperados.
- **Ejecutado en Godot 4.7.2-stable (consola, modo headless), según lo informó Claude Code en el equipo del grupo:**
  `--script res://scripts/pruebas_manuales.gd` -> 17 pruebas, 0 fallos, código de salida 0;
  `--quit` -> el proyecto cargó sin errores ni advertencias, código de salida 0.
- **Aún sin verificar:** la ejecución visual (F5). El modo headless no dibuja la escena, así que el
  comportamiento de rebotes, contadores, HUD y monedas sigue pendiente de probarse a mano y de capturarse.

## Fuentes y autoría (criterio I3 de la rúbrica)

- Teoría: Ericson (2004); Kansas State University (s. f.); documentación oficial de Godot (ver referencias de la presentación).
- Estructura de nodos y señales: siguen la documentación oficial de Godot ("Physics introduction",
  "Using Area2D", "Using CharacterBody2D/3D").
- El código fue generado con asistencia de IA (Claude, Anthropic) a partir de las instrucciones del grupo.
  **Completar:** qué partes revisó, adaptó o modificó cada integrante del equipo.
