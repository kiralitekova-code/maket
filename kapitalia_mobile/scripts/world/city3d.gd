class_name City3D
extends Node3D

# ==============================================================================
# KAPITALIA 3D — Главный узел 3D-города
# АРХИТЕКТУРА: процедурная генерация кварталов (CityBuilder)
# ФИЗИКА: CharacterBody3D игрок + StaticBody3D здания
# ЛОГИКА: привязка предприятий, открытие карточек, экономика в реальном времени
# ==============================================================================

signal enterprise_selected(enterprise_id: String, name: String)
signal world_ready()

var _city_builder: CityBuilder
var _player: PlayerController
var _camera_rig: CameraRig
var _game_state: GameState = null
var _initialized: bool = false


func _ready() -> void:
	_build_world()


## Построить весь 3D-мир
func _build_world() -> void:
	# ── Освещение (солнце + небо) ──
	_setup_environment()
	
	# ── Город (процедурная архитектура) ──
	_city_builder = CityBuilder.new()
	_city_builder.name = "CityBuilder"
	_city_builder.building_clicked.connect(_on_building_clicked)
	add_child(_city_builder)
	
	# ── Игрок (физика) ──
	_player = PlayerController.new()
	_player.name = "Player"
	_player.position = Vector3(24, 1.0, 24)  # центр города
	
	# Физика игрока: коллизия-капсула
	var col_shape := CollisionShape3D.new()
	col_shape.name = "CollisionShape3D"
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.5
	capsule.height = 2.0
	col_shape.shape = capsule
	_player.add_child(col_shape)
	
	# Голова с камерой (вид от первого лица)
	var head := Node3D.new()
	head.name = "Head"
	head.position = Vector3(0, 1.6, 0)
	_player.add_child(head)
	
	var p_cam := Camera3D.new()
	p_cam.name = "Camera3D"
	p_cam.fov = 75.0
	head.add_child(p_cam)
	
	add_child(_player)
	
	# ── Камера-риг (математика орбиты) ──
	_camera_rig = CameraRig.new()
	_camera_rig.name = "CameraRig"
	_camera_rig.target = _player
	var rig_cam := Camera3D.new()
	rig_cam.name = "Camera3D"
	rig_cam.fov = 70.0
	_camera_rig.add_child(rig_cam)
	add_child(_camera_rig)
	_camera_rig.global_position = _player.global_position
	
	# ── Джойстик (мобильное управление) ──
	_build_virtual_joystick()
	
	_initialized = true
	world_ready.emit()


## Среда: небо, солнце, туман, свет
func _setup_environment() -> void:
	# Небо
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = Sky.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color("#0E1116")
	sky_mat.sky_horizon_color = Color("#1C232C")
	sky_mat.ground_bottom_color = Color("#0E1116")
	sky_mat.ground_horizon_color = Color("#2A323D")
	env.sky.sky_material = sky_mat
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_color = Color("#93A1B0")
	env.ambient_light_energy = 1.0
	env.fog_enabled = true
	env.fog_light_color = Color("#151A21")
	env.fog_density = 0.008
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	
	var world_env := WorldEnvironment.new()
	world_env.environment = env
	add_child(world_env)
	
	# Солнце
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, 30, 0)
	sun.light_color = Color("#E6EDF3")
	sun.light_energy = 1.2
	sun.shadow_enabled = true
	add_child(sun)


## Виртуальный джойстик (экранный, для мобильного)
func _build_virtual_joystick() -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "JoystickLayer"
	canvas.layer = 10
	add_child(canvas)
	
	# Левая половина — зона джойстика
	var joy_area := Control.new()
	joy_area.name = "JoystickArea"
	joy_area.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	joy_area.custom_minimum_size = Vector2(160, 160)
	joy_area.offset_left = 20
	joy_area.offset_top = -180
	joy_area.offset_right = 180
	joy_area.offset_bottom = -20
	canvas.add_child(joy_area)
	
	var joy_base := Panel.new()
	joy_base.name = "JoyBase"
	joy_base.set_anchors_preset(Control.PRESET_FULL_RECT)
	joy_base.modulate = Color(1, 1, 1, 0.3)
	joy_area.add_child(joy_base)
	
	var joy_knob := Panel.new()
	joy_knob.name = "JoyKnob"
	joy_knob.custom_minimum_size = Vector2(48, 48)
	joy_knob.position = Vector2(66, 66)
	joy_area.add_child(joy_knob)
	
	# Обработка касаний в зоне джойстика
	joy_area.gui_input.connect(func(event: InputEvent):
		if event is InputEventScreenDrag:
			var center: Vector2 = joy_area.size / 2.0
			var rel: Vector2 = event.position - center
			rel = rel.limit_length(70.0)
			joy_knob.position = center + rel - Vector2(24, 24)
			if _player:
				_player.set_joystick(rel / 70.0)
		elif event is InputEventScreenTouch and not event.pressed:
			joy_knob.position = Vector2(66, 66)
			if _player:
				_player.set_joystick(Vector2.ZERO)
	)
	
	# Подсказка
	var hint := Label.new()
	hint.text = "Свайп — джойстик · Пинч — зум · Касание здания — детали"
	hint.position = Vector2(10, 20)
	hint.modulate = Color(1, 1, 1, 0.5)
	canvas.add_child(hint)


## Привязать GameState (вызывается из AppShell)
func bind_game_state(state: GameState) -> void:
	_game_state = state
	if _city_builder and _game_state:
		_city_builder.bind_game_state(_game_state)


## Получить игрока (для камеры/слежения)
func get_player() -> PlayerController:
	return _player


func _on_building_clicked(eid: String, name: String) -> void:
	enterprise_selected.emit(eid, name)
