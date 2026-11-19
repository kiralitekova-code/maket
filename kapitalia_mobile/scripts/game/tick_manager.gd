class_name TickManager
extends Node

# ==============================================================================
# KAPITALIA Mobile — Менеджер игровых тиков
# Отвечает за: таймер тиков, экономику, обновление котировок, производство
# ==============================================================================

signal tick_started(week: int, day: int, tick: int)
signal economy_updated()
signal production_completed(enterprise_id: String, output: Dictionary)

@export var tick_duration_seconds: float = 60.0  # 1 тик = 1 минута (для демо)
@export var auto_start: bool = true

var _timer: Timer
var _game_state: GameState


func _ready() -> void:
	_game_state = GameState.new()
	add_child(_game_state)
	
	_timer = Timer.new()
	_timer.wait_time = tick_duration_seconds
	_timer.one_shot = false
	_timer.timeout.connect(_on_tick_timeout)
	add_child(_timer)
	
	if auto_start:
		start()


## Запустить тики
func start() -> void:
	_timer.start()


## Остановить тики
func stop() -> void:
	_timer.stop()


## Принудительный шаг тика
func force_tick() -> void:
	_process_tick()


func _on_tick_timeout() -> void:
	_process_tick()


func _process_tick() -> void:
	_game_state.advance_tick()
	
	# Обновление экономики
	_update_economy()
	
	# Производство на предприятиях
	_process_production()
	
	# Проверка контрактов
	_process_contracts()
	
	# Генерация алертов
	_generate_alerts()
	
	tick_started.emit(_game_state.week, _game_state.day, _game_state.tick)
	economy_updated.emit()


func _update_economy() -> void:
	# Здесь будет логика изменения цен, спроса, индексов
	# Для демо: заглушка
	pass


func _process_production() -> void:
	for enterprise_id in _game_state.enterprises:
		var data: Dictionary = _game_state.enterprises[enterprise_id]
		if data.status == "working":
			var output: Dictionary = {
				"product": _get_product_for_enterprise(enterprise_id),
				"quantity": data.production_per_tick * data.efficiency
			}
			# Добавить на склад
			var item_id: String = output.product
			var current: float = _game_state.inventory.get(item_id, 0.0)
			_game_state.set_inventory(item_id, current + output.quantity)
			production_completed.emit(enterprise_id, output)


func _get_product_for_enterprise(enterprise_id: String) -> String:
	match enterprise_id:
		"bakery_01", "bakery_02":
			return "bread_wheat"
		"mill_01":
			return "flour_premium"
		"elevator_04":
			return "grain_wheat"
	return "unknown"


func _process_contracts() -> void:
	for contract in _game_state.contracts:
		if contract.status == "active":
			contract.deadline_tick -= 1
			if contract.deadline_tick <= 0:
				# Контракт завершён
				complete_contract(contract)


func complete_contract(contract: Dictionary) -> void:
	contract.status = "completed"
	var total: int = contract.volume_tons * contract.price_per_ton
	_game_state.add_balance(-total)  # Оплата поставщику


func _generate_alerts() -> void:
	# Проверка критических остатков
	for item_id in _game_state.inventory:
		var qty: float = _game_state.inventory[item_id]
		if qty < 20.0:  # Меньше 2 тиков запаса
			_create_low_stock_alert(item_id, qty)


func _create_low_stock_alert(item_id: String, qty: float) -> void:
	# Проверить, нет ли уже такого алерта
	for alert in _game_state.alerts:
		if alert.get("item_id") == item_id and alert.category == "critical":
			return
	
	var new_alert: Dictionary = {
		"id": "ALT-LOW-%s" % item_id,
		"category": "critical",
		"title": "Дефицит: %s" % item_id,
		"description": "Остаток %.1f т. Хватит на ~2 тика." % qty,
		"priority": 1,
		"timestamp": Time.get_unix_time_from_system(),
		"item_id": item_id
	}
	_game_state.alerts.append(new_alert)


## Получить доступное количество товара на складе
func get_inventory(item_id: String) -> float:
	return _game_state.inventory.get(item_id, 0.0)


## Получить баланс
func get_balance() -> int:
	return _game_state.balance


## Получить время
func get_time() -> Dictionary:
	return {
		"week": _game_state.week,
		"day": _game_state.day,
		"tick": _game_state.tick,
		"time_string": _game_state.get_time_string(),
		"countdown": _game_state.get_tick_countdown()
	}
