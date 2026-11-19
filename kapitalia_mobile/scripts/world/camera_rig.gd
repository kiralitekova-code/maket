class_name CameraRig
extends Node3D

# ==============================================================================
# KAPITALIA 3D — Камера-риг
# ГЕОМЕТРИЯ: орбитальная камера вокруг цели
# МАТЕМАТИКА: сферические координаты (rho, theta, phi) → декартовы (x, y, z)
# Управление: свайп для вращения, пинч для зума, колесо мыши
# ==============================================================================

# ── Сферические параметры ──
@export var distance: float = 28.0         # радиус (rho)
@export var min_distance: float = 10.0
@export var max_distance: float = 60.0
@export var yaw: float = 45.0              # угол вокруг Y (theta), градусы
@export var pitch: float = 35.0            # угол возвышения (phi), градусы
@export var rotation_speed: float = 0.4    # градусов на пиксель свайпа
@export var zoom_speed: float = 0.05       # множитель зума (пинч/колесо)

var target: Node3D = null                  # цель слежения (игрок)

# ── Состояние свайпа ──
var _pinch_distance: float = 0.0
var _touch_count: int = 0

@onready var _camera: Camera3D = $Camera3D


func _ready() -> void:
	_update_camera_transform()


func _process(delta: float) -> void:
	# Следование за целью
	if target:
		global_position = target.global_position
	
	_update_camera_transform()
	
	# Колесо мыши (десктоп)
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_UP):
		zoom(1.1)
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_DOWN):
		zoom(0.9)


## Обновить позицию камеры по сферическим координатам
func _update_camera_transform() -> void:
	# МАТЕМАТИКА: сферика → декартовы
	var yaw_rad: float = deg_to_rad(yaw)
	var pitch_rad: float = deg_to_rad(pitch)
	
	var x: float = distance * cos(pitch_rad) * sin(yaw_rad)
	var y: float = distance * sin(pitch_rad)
	var z: float = distance * cos(pitch_rad) * cos(yaw_rad)
	
	_camera.position = Vector3(x, y, z)
	_camera.look_at(Vector3.ZERO + Vector3(0, 2.0, 0))


## Вращение камеры (свайп/мышь)
func orbit(delta_x: float, delta_y: float) -> void:
	yaw -= delta_x * rotation_speed
	pitch = clampf(pitch - delta_y * rotation_speed, 5.0, 80.0)
	_update_camera_transform()


## Зум (пинч/колесо)
func zoom(factor: float) -> void:
	distance = clampf(distance * factor, min_distance, max_distance)
	_update_camera_transform()


## Обработка касаний (мобильное управление)
func _unhandled_input(event: InputEvent) -> void:
	# ── Мышь: зажата ЛКМ → вращение ──
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		orbit(event.relative.x, event.relative.y)
	
	# ── Тач: 1 палец — вращение, 2 пальца — зум ──
	elif event is InputEventScreenTouch:
		if event.pressed:
			_touch_count += 1
			if _touch_count == 2:
				_pinch_distance = _get_touch_distance()
		else:
			_touch_count = maxi(0, _touch_count - 1)
			if _touch_count < 2:
				_pinch_distance = 0.0
	
	elif event is InputEventScreenDrag:
		if _touch_count == 1:
			orbit(event.relative.x, event.relative.y)
		elif _touch_count >= 2:
			var new_dist: float = _get_touch_distance()
			if _pinch_distance > 0.0:
				var factor: float = _pinch_distance / new_dist
				zoom(factor)
			_pinch_distance = new_dist


## Получить расстояние между двумя пальцами
func _get_touch_distance() -> float:
	# Для двух пальцев используем события из InputEventScreenDrag
	# Упрощённо: используем последнее известное — для демо фиксируем
	return _pinch_distance if _pinch_distance > 0.0 else 100.0
