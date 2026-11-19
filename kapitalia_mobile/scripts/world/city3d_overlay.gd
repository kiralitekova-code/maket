extends Control

# ==============================================================================
# KAPITALIA 3D — Оверлей 3D-города поверх мобильного UI
# Управляет: 3D-сценой (City3D), HUD, карточкой предприятия, возвратом
# ==============================================================================

signal close_requested()

var _city: City3D
var _game_state: GameState = null
var _selected_enterprise: String = ""

@onready var _back_button: Button = %BackButton
@onready var _enterprise_card: PanelContainer = %EnterpriseCard
@onready var _card_name: Label = %CardName
@onready var _card_city: Label = %CardCity
@onready var _card_status: Label = %CardStatus
@onready var _card_efficiency: Label = %CardEfficiency
@onready var _card_production: Label = %CardProduction
@onready var _hint_label: Label = %HintLabel


func _ready() -> void:
	_back_button.pressed.connect(_on_back)
	_enterprise_card.visible = false
	
	# Построить 3D-мир
	_build_city()


## Построить 3D-город и связать с игровым состоянием
func _build_city() -> void:
	var city_scene: PackedScene = load("res://scenes/world/city3d.tscn")
	_city = city_scene.instantiate() as City3D
	_city.name = "City"
	
	# Вставить в SubViewport (3D живёт в отдельном вьюпорте под UI)
	var viewport: SubViewport = %CityViewport
	viewport.add_child(_city)
	
	# Привязать GameState (найти через дерево: оверлей → AppShell → GameCore → TickManager → GameState)
	_find_and_bind_game_state()
	
	# Сигнал выбора здания → карточка
	if _city:
		_city.enterprise_selected.connect(_on_enterprise_selected)


func _find_and_bind_game_state() -> void:
	var app_shell := get_tree().current_scene
	if app_shell:
		var game_core: Node = app_shell.get_node_or_null("GameCore")
		if game_core:
			var tick_mgr: Node = game_core.get_node_or_null("TickManager")
			if tick_mgr:
				_game_state = tick_mgr.get_node_or_null("GameState") as GameState
	if _game_state and _city:
		_city.bind_game_state(_game_state)


func _on_back() -> void:
	close_requested.emit()


## Клик по зданию → показать карточку предприятия
func _on_enterprise_selected(eid: String, name: String) -> void:
	_selected_enterprise = eid
	_enterprise_card.visible = true
	
	_card_name.text = name
	_card_city.text = "Город: %s" % _get_enterprise_city(eid)
	_card_status.text = "Статус: %s" % _get_enterprise_status(eid)
	_card_efficiency.text = "Эффективность: %.0f%%" % (_get_enterprise_eff(eid) * 100.0)
	_card_production.text = "Производство: %.1f т/тик" % _get_enterprise_prod(eid)
	
	_hint_label.text = "Выбрано: %s" % name


func _get_enterprise_city(eid: String) -> String:
	if _game_state and _game_state.enterprises.has(eid):
		return _game_state.enterprises[eid].get("city", "—")
	return "—"


func _get_enterprise_status(eid: String) -> String:
	if _game_state and _game_state.enterprises.has(eid):
		var st: String = _game_state.enterprises[eid].get("status", "unknown")
		match st:
			"working": return "Работает"
			"low_stock": return "Дефицит сырья"
			"idle": return "Простой"
	return "—"


func _get_enterprise_eff(eid: String) -> float:
	if _game_state and _game_state.enterprises.has(eid):
		return _game_state.enterprises[eid].get("efficiency", 0.0)
	return 0.0


func _get_enterprise_prod(eid: String) -> float:
	if _game_state and _game_state.enterprises.has(eid):
		return _game_state.enterprises[eid].get("production_per_tick", 0.0)
	return 0.0


## Закрыть карточку
func _on_card_close() -> void:
	_enterprise_card.visible = false
	_selected_enterprise = ""
	_hint_label.text = "Касание здания — детали предприятия"
