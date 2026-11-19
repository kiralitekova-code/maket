class_name PlayerController
extends CharacterBody3D

# ==============================================================================
# KAPITALIA 3D — Контроллер игрока
# ФИЗИКА: CharacterBody3D, гравитация, коллизии, скорость, скольжение по стенам
# Управление: WASD/стрелки на ПК, виртуальный джойстик/свайп на мобильном
# ==============================================================================

@export var move_speed: float = 8.0            # м/с
@export var acceleration: float = 12.0         # плавное ускорение
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.002
@export var gravity: float = 9.8

# ── Виртуальный джойстик (мобильный) ──
var joystick_vector: Vector2 = Vector2.ZERO

# ── Внутренние ──
var _velocity: Vector3 = Vector3.ZERO
var _camera: Camera3D
var _input_dir: Vector3 = Vector3.ZERO
var _is_mobile: bool = false

@onready var _head: Node3D = $Head
@onready var _collision: CollisionShape3D = $CollisionShape3D


func _ready() -> void:
	_is_mobile = DisplayServer.get_name() != "Windows" or OS.has_feature("mobile")
	_camera = _head.get_node_or_null("Camera3D") as Camera3D


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		_velocity.y -= gravity * delta
	
	# ── Получение ввода (ПК клавиатура / мобильный джойстик) ──
	_input_dir = _read_input()
	
	# Направление относительно камеры (Y-плоскость)
	var camera_forward: Vector3 = Vector3.ZERO
	var camera_right: Vector3 = Vector3.ZERO
	if _camera:
		var forward: Vector3 = -_camera.global_transform.basis.z
		forward.y = 0.0
		forward = forward.normalized()
		camera_forward = forward
		camera_right = forward.cross(Vector3.UP).normalized()
	
	var move_dir: Vector3 = (camera_forward * _input_dir.z + camera_right * _input_dir.x).normalized()
	
	# ── ФИЗИКА: горизонтальная скорость с ускорением ──
	var target_h: Vector3 = move_dir * move_speed
	_velocity.x = lerpf(_velocity.x, target_h.x, acceleration * delta)
	_velocity.z = lerpf(_velocity.z, target_h.z, acceleration * delta)
	
	# ── ФИЗИКА: перемещение с коллизиями ──
	velocity = _velocity
	move_and_slide()
	
	# Синхронизация после коллизий (скольжение по стенам)
	_velocity = velocity
	
	# Прыжок
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		_velocity.y = jump_velocity
	
	# ── Поворот персонажа по направлению движения ──
	if move_dir.length() > 0.1:
		var target_yaw: float = atan2(move_dir.x, move_dir.z)
		rotation.y = lerp_angle(rotation.y, target_yaw, 10.0 * delta)


## Чтение ввода: клавиатура или виртуальный джойстик
func _read_input() -> Vector3:
	var input: Vector3 = Vector3.ZERO
	
	# Клавиатура (десктоп)
	var kx: float = Input.get_axis("ui_left", "ui_right")
	var kz: float = Input.get_axis("ui_up", "ui_down")
	
	# Джойстик (мобильный)
	var jx: float = joystick_vector.x
	var jy: float = joystick_vector.y
	
	var x: float = kx if absf(kx) > absf(jx) else jx
	var z: float = kz if absf(kz) > absf(jy) else jy
	
	input.x = x
	input.z = z
	return input


## Установить вектор виртуального джойстика (-1..1)
func set_joystick(vec: Vector2) -> void:
	joystick_vector = vec


## Установить вращение камеры (панорама мышью/свайпом)
func rotate_view(yaw_delta: float, pitch_delta: float) -> void:
	if _camera:
		_camera.rotation.x = clampf(_camera.rotation.x - pitch_delta * mouse_sensitivity, -1.2, 1.2)
		_camera.rotation.y = yaw_delta  # используется camera_rig для орбиты
