class_name CityBuilder
extends Node3D

# ==============================================================================
# KAPITALIA 3D — Процедурный генератор города
# Архитектура + Геометрия + Математика
#
# Строит сетку улиц, кварталы, здания с коллизиями (StaticBody3D),
# привязывает предприятия из GameState к конкретным зданиям.
# ==============================================================================

signal building_clicked(enterprise_id: String, building_name: String)

# ── Параметры города ──
@export var grid_size: int = 8            # 8×8 кварталов
@export var block_size: float = 12.0      # размер квартала (м)
@export var road_width: float = 6.0       # ширина улицы (м)
@export var building_height_min: float = 4.0
@export var building_height_max: float = 24.0
@export var seed: int = 20241119

# ── Материалы (архитектурная палитра) ──
var _mats: Dictionary = {}

# ── Ссылки на здания-предприятия ──
var enterprise_nodes: Dictionary = {}   # enterprise_id -> Node3D
var _game_state: GameState = null

# ── Внутренняя математика ──
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _street_cell: float = 0.0           # шаг сетки (block + road)
var _world_center: Vector3 = Vector3.ZERO


func _ready() -> void:
	_rng.seed = seed
	_build_palette()
	_street_cell = block_size + road_width
	_world_center = Vector3(grid_size * _street_cell / 2.0, 0.0, grid_size * _street_cell / 2.0)
	
	_build_ground()
	_build_road_network()
	_build_city_blocks()
	_build_city_walls()


## Получить и привязать игровое состояние (предприятия)
func bind_game_state(state: GameState) -> void:
	_game_state = state
	if _game_state:
		_map_enterprises_to_buildings()


# ──────────────────────────────────────────────────────────────────────────────
# АРХИТЕКТУРА: Палитра
# ──────────────────────────────────────────────────────────────────────────────
func _build_palette() -> void:
	_mats["ground"] = StandardMaterial3D.new()
	_mats["ground"].albedo_color = Color("#2A323D")
	_mats["ground"].roughness = 0.95
	
	_mats["road"] = StandardMaterial3D.new()
	_mats["road"].albedo_color = Color("#1C232C")
	_mats["road"].roughness = 0.9
	
	_mats["road_line"] = StandardMaterial3D.new()
	_mats["road_line"].albedo_color = Color("#F2A93B")
	_mats["road_line"].emission_enabled = true
	_mats["road_line"].emission = Color("#F2A93B")
	_mats["road_line"].emission_energy_multiplier = 0.3
	
	# Коммерческие (биржа, конторы) — синие
	_mats["commercial"] = StandardMaterial3D.new()
	_mats["commercial"].albedo_color = Color("#4C8DFF")
	_mats["commercial"].roughness = 0.4
	_mats["commercial"].metallic = 0.2
	
	# Промышленные (заводы, мельницы) — янтарные
	_mats["industrial"] = StandardMaterial3D.new()
	_mats["industrial"].albedo_color = Color("#F2A93B")
	_mats["industrial"].roughness = 0.6
	
	# Жилые — бирюзовые (прибыль)
	_mats["residential"] = StandardMaterial3D.new()
	_mats["residential"].albedo_color = Color("#2DD4BF")
	_mats["residential"].roughness = 0.7
	
	# Склады — серые
	_mats["storage"] = StandardMaterial3D.new()
	_mats["storage"].albedo_color = Color("#64748B")
	_mats["storage"].roughness = 0.8
	
	# Логистика — красные
	_mats["logistics"] = StandardMaterial3D.new()
	_mats["logistics"].albedo_color = Color("#F2555A")
	_mats["logistics"].roughness = 0.5
	
	# Универсальный
	_mats["generic"] = StandardMaterial3D.new()
	_mats["generic"].albedo_color = Color("#93A1B0")
	_mats["generic"].roughness = 0.7
	
	# Окна (эмиссия для ночного вида)
	_mats["window"] = StandardMaterial3D.new()
	_mats["window"].albedo_color = Color("#E6EDF3")
	_mats["window"].emission_enabled = true
	_mats["window"].emission = Color("#E6EDF3")
	_mats["window"].emission_energy_multiplier = 0.8


# ──────────────────────────────────────────────────────────────────────────────
# ГЕОМЕТРИЯ: Земля
# ──────────────────────────────────────────────────────────────────────────────
func _build_ground() -> void:
	var size: float = grid_size * _street_cell + road_width
	var ground := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(size * 2.0, size * 2.0)
	ground.mesh = plane
	ground.position = _world_center
	ground.position.y = -0.05
	ground.material_override = _mats["ground"]
	add_child(ground)
	
	# Коллизия земли
	var body := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(size * 2.0, 1.0, size * 2.0)
	shape.shape = box
	body.add_child(shape)
	body.position = _world_center
	body.position.y = -1.05
	add_child(body)


# ──────────────────────────────────────────────────────────────────────────────
# ГЕОМЕТРИЯ: Сеть дорог (улицы-сетка)
# ──────────────────────────────────────────────────────────────────────────────
func _build_road_network() -> void:
	var total: int = grid_size + 1
	var city_len: float = grid_size * _street_cell + road_width
	
	for i in range(total):
		# Горизонтальная дорога
		_build_road_strip(
			Vector3(city_len / 2.0, 0.02, i * _street_cell),
			Vector3(city_len, road_width, 1.0)
		)
		# Вертикальная дорога
		_build_road_strip(
			Vector3(i * _street_cell, 0.02, city_len / 2.0),
			Vector3(road_width, 1.0, city_len)
		)
	
	# Центральная площадь (пересечение — рынок)
	_build_central_plaza()


func _build_road_strip(pos: Vector3, size: Vector3) -> void:
	var road := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	road.mesh = box
	road.position = pos
	road.material_override = _mats["road"]
	add_child(road)
	
	# Коллизия дороги (не проваливаться, но можно ходить)
	# Дороги плоские — коллизия не нужна, только земля


func _build_central_plaza() -> void:
	var center := Vector3(_world_center.x, 0.03, _world_center.z)
	var plaza := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = block_size * 1.2
	cyl.bottom_radius = block_size * 1.2
	cyl.height = 0.1
	plaza.mesh = cyl
	plaza.position = center
	plaza.material_override = _mats["road"]
	add_child(plaza)
	
	# Маркер рынка — светящаяся колонна
	var marker := MeshInstance3D.new()
	var col := CylinderMesh.new()
	col.top_radius = 0.5
	col.bottom_radius = 0.5
	col.height = 8.0
	marker.mesh = col
	marker.position = center + Vector3(0, 4.0, 0)
	marker.material_override = _mats["road_line"]
	add_child(marker)
	
	# Точечный свет на площади
	var light := OmniLight3D.new()
	light.position = center + Vector3(0, 6.0, 0)
	light.light_color = Color("#F2A93B")
	light.light_energy = 3.0
	light.omni_range = 18.0
	add_child(light)


# ──────────────────────────────────────────────────────────────────────────────
# АРХИТЕКТУРА: Кварталы и здания
# ──────────────────────────────────────────────────────────────────────────────
func _build_city_blocks() -> void:
	for gx in range(grid_size):
		for gz in range(grid_size):
			var block_pos := Vector3(
				gx * _street_cell + road_width / 2.0 + block_size / 2.0,
				0.0,
				gz * _street_cell + road_width / 2.0 + block_size / 2.0
			)
			_build_block(gx, gz, block_pos)


## Квартал: 2×2 здания с внутренним двором
func _build_block(gx: int, gz: int, pos: Vector3) -> void:
	var quarter: float = block_size / 2.0 - 0.6  # отступ от края квартала
	var building_size: float = quarter - 0.3
	
	# 4 здания в квартале (углы)
	var offsets: Array[Vector3] = [
		Vector3(-quarter / 2.0 - 0.2, 0, -quarter / 2.0 - 0.2),
		Vector3(quarter / 2.0 + 0.2, 0, -quarter / 2.0 - 0.2),
		Vector3(-quarter / 2.0 - 0.2, 0, quarter / 2.0 + 0.2),
		Vector3(quarter / 2.0 + 0.2, 0, quarter / 2.0 + 0.2),
	]
	
	var idx: int = gx * grid_size + gz
	for i in range(offsets.size()):
		var bpos: Vector3 = pos + offsets[i]
		_build_building(
			bpos,
			building_size,
			_building_type(idx, i),
			idx * 4 + i
		)


## Тип здания: распределение по кварталам города
func _building_type(block_idx: int, corner: int) -> String:
	# Определяем зоны города по квадрантам
	var quad: int = (block_idx % 2) * 2 + (corner % 2)
	var zone: int = block_idx % 4
	match zone:
		0:
			return ["commercial", "residential", "industrial", "storage"][quad % 4]
		1:
			return ["industrial", "storage", "commercial", "logistics"][quad % 4]
		2:
			return ["residential", "commercial", "storage", "generic"][quad % 4]
		_:
			return ["logistics", "industrial", "residential", "generic"][quad % 4]


# ──────────────────────────────────────────────────────────────────────────────
# МАТЕМАТИКА + ГЕОМЕТРИЯ: Построение одного здания
# ──────────────────────────────────────────────────────────────────────────────
func _build_building(pos: Vector3, footprint: float, btype: String, uid: int) -> void:
	# Математика: высота — логнормальное распределение с шумом
	var height: float = _building_height(btype, uid)
	
	# Случайные габариты (чуть варьируем, сохраняя коллизию квадратной)
	var w: float = footprint * _rng.randf_range(0.75, 0.95)
	var d: float = footprint * _rng.randf_range(0.75, 0.95)
	
	# Основной объём здания
	var body := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(w, height, d)
	body.mesh = box
	body.position = pos + Vector3(0, height / 2.0, 0)
	body.material_override = _mats[btype]
	add_child(body)
	
	# Крыша — чуть светлее (эмиссия по типу)
	var roof := MeshInstance3D.new()
	var rbox := BoxMesh.new()
	rbox.size = Vector3(w * 1.05, 0.3, d * 1.05)
	roof.mesh = rbox
	roof.position = pos + Vector3(0, height + 0.15, 0)
	roof.material_override = _mats[btype]
	add_child(roof)
	
	# Окна (полоски на фасаде) — эмиссия, математика: каждые 2 м по высоте
	if height > 6.0:
		var window_strip := MeshInstance3D.new()
		var wbox := BoxMesh.new()
		wbox.size = Vector3(w * 0.7, minf(height * 0.4, 5.0), 0.05)
		window_strip.mesh = wbox
		window_strip.position = pos + Vector3(0, height * 0.55, d / 2.0 + 0.03)
		window_strip.material_override = _mats["window"]
		add_child(window_strip)
	
	# ФИЗИКА: статичная коллизия здания (CharacterBody3D игрока не пройдёт)
	var body_col := StaticBody3D.new()
	body_col.name = "BuildingCollision_%d" % uid
	body_col.collision_layer = 1  # world
	body_col.collision_mask = 1
	
	var shape := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = Vector3(w, height, d)
	shape.shape = box_shape
	body_col.add_child(shape)
	body_col.position = pos + Vector3(0, height / 2.0, 0)
	add_child(body_col)
	
	# Метка-название (для ориентира)
	var label := _create_building_label(btype, uid)
	label.position = pos + Vector3(0, height + 1.2, 0)
	add_child(label)


## Математика высоты: база + нормальное распределение + шум по синусу
func _building_height(btype: String, uid: int) -> float:
	var base: float = 0.0
	match btype:
		"commercial": base = 18.0
		"industrial": base = 10.0
		"residential": base = 14.0
		"storage":    base = 6.0
		"logistics":  base = 8.0
		_:            base = 12.0
	
	# Синус-шум по координате (детерминированная математика)
	var noise: float = sin(float(uid) * 1.618) * 0.25 + cos(float(uid) * 0.618) * 0.15
	var jitter: float = _rng.randf_range(-0.15, 0.15)
	var h: float = base * (1.0 + noise + jitter)
	return clampf(h, building_height_min, building_height_max)


## 3D-текст-метка (Label3D)
func _create_building_label(btype: String, uid: int) -> Label3D:
	var label := Label3D.new()
	label.text = _type_label(btype)
	label.font_size = 96
	label.pixel_size = 0.01
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.modulate = Color("#E6EDF3")
	label.outline_size = 24
	label.outline_modulate = Color("#0E1116")
	label.no_depth_test = true
	return label


func _type_label(btype: String) -> String:
	match btype:
		"commercial":  return "БИРЖА"
		"industrial":  return "ЗАВОД"
		"residential": return "ЖИЛОЙ"
		"storage":     return "СКЛАД"
		"logistics":   return "ЛОГИСТИКА"
		_:             return "ОФИС"


# ──────────────────────────────────────────────────────────────────────────────
# ГЕОМЕТРИЯ: Стены города (граница мира)
# ──────────────────────────────────────────────────────────────────────────────
func _build_city_walls() -> void:
	var size: float = grid_size * _street_cell + road_width
	var wall_h: float = 3.0
	var wall_t: float = 1.0
	var half: float = size / 2.0
	
	# 4 стены по периметру + коллизии
	var wall_positions: Array[Vector3] = [
		Vector3(half, wall_h / 2.0, -half), Vector3(half, wall_h / 2.0, size + half),
		Vector3(-half, wall_h / 2.0, half), Vector3(size + half, wall_h / 2.0, half),
	]
	var wall_sizes: Array[Vector3] = [
		Vector3(size + wall_t * 2.0, wall_h, wall_t),
		Vector3(size + wall_t * 2.0, wall_h, wall_t),
		Vector3(wall_t, wall_h, size + wall_t * 2.0),
		Vector3(wall_t, wall_h, size + wall_t * 2.0),
	]
	
	for i in range(4):
		var wall := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = wall_sizes[i]
		wall.mesh = box
		wall.position = wall_positions[i]
		wall.material_override = _mats["road"]
		add_child(wall)
		
		var col := StaticBody3D.new()
		var shape := CollisionShape3D.new()
		var bs := BoxShape3D.new()
		bs.size = wall_sizes[i]
		shape.shape = bs
		col.add_child(shape)
		col.position = wall_positions[i]
		add_child(col)


# ──────────────────────────────────────────────────────────────────────────────
# ЛОГИКА: Привязка предприятий к зданиям (для кликов)
# ──────────────────────────────────────────────────────────────────────────────
func _map_enterprises_to_buildings() -> void:
	# Берём предприятия из GameState и помечаем здания-владельцев
	var enterprises: Dictionary = _game_state.enterprises if _game_state else {}
	var ids: Array = enterprises.keys()
	if ids.is_empty():
		return
	
	# Собираем все MeshInstance зданий и раздаём по одному на предприятие
	var building_meshes: Array[MeshInstance3D] = []
	_collect_buildings(self, building_meshes)
	
	for i in range(mini(ids.size(), building_meshes.size())):
		var eid: String = ids[i]
		var mesh: MeshInstance3D = building_meshes[i]
		var data: Dictionary = enterprises[eid]
		
		# Оборачиваем в Area3D для клика
		var area := Area3D.new()
		area.name = "Area_%s" % eid
		area.set_meta("enterprise_id", eid)
		area.set_meta("building_name", data.get("name", eid))
		
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		# Используем размеры исходного бокса
		var src: BoxMesh = mesh.mesh as BoxMesh
		if src:
			box.size = src.size + Vector3(0.5, 0.5, 0.5)
		shape.shape = box
		area.add_child(shape)
		
		area.position = mesh.position
		area.input_event.connect(_on_building_input.bind(eid))
		add_child(area)
		
		enterprise_nodes[eid] = area


## Рекурсивный сбор мешей-зданий
func _collect_buildings(node: Node, result: Array[MeshInstance3D]) -> void:
	for child in node.get_children():
		if child is MeshInstance3D and child.mesh is BoxMesh:
			result.append(child)
		_collect_buildings(child, result)


func _on_building_input(viewport: Node, event: InputEvent, shape_idx: int, eid: String) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var data: Dictionary = _game_state.enterprises.get(eid, {}) if _game_state else {}
		building_clicked.emit(eid, data.get("name", eid))
	elif event is InputEventScreenTouch and event.pressed:
		var data: Dictionary = _game_state.enterprises.get(eid, {}) if _game_state else {}
		building_clicked.emit(eid, data.get("name", eid))
