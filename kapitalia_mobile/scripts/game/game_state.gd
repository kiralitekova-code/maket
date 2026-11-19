class_name GameState
extends Node

# ==============================================================================
# KAPITALIA Mobile — Глобальное состояние игры
# Хранит: CR-баланс, текущую неделю/день/тик, статистику, инвентарь
# ==============================================================================

signal balance_changed(new_balance: int)
signal tick_changed(week: int, day: int, tick_in_week: int)
signal inventory_changed(item_id: String, quantity: int)

# Баланс в CR (целые числа, хранение в копейках не требуется)
@export var balance: int = 5_240_000

# Время: неделя 1-52, день 0-6 (Пн-Вс), тик внутри дня (0-23)
@export var week: int = 12
@export var day: int = 3  # Четверг
@export var tick: int = 0

# Статистика
@export var total_revenue: int = 0
@export var total_expenses: int = 0
@export var net_profit: int = 0

# Склад: { item_id: quantity_tons }
var inventory: Dictionary = {}

# Предприятия: { enterprise_id: EnterpriseData }
var enterprises: Dictionary = {}

# Активные контракты: [{id, city, product, volume, price, deadline, status}]
var contracts: Array = []

# Алерты: [{id, category, title, description, priority, timestamp}]
var alerts: Array = []


func _ready() -> void:
	# Начальные данные для демонстрации
	_init_mock_data()


func _init_mock_data() -> void:
	# Стартовый инвентарь
	inventory = {
		"flour_premium": 45.0,
		"sugar_white": 28.0,
		"grain_wheat": 120.0,
		"diesel_l62": 35.0
	}
	
	# Пример предприятия
	enterprises = {
		"bakery_01": {
			"name": "Пекарный завод №1",
			"city": "Нордхейм",
			"efficiency": 0.92,
			"status": "working",
			"production_per_tick": 12.0
		},
		"bakery_02": {
			"name": "Пекарный завод №2",
			"city": "Нордхейм",
			"efficiency": 0.74,
			"status": "low_stock",
			"production_per_tick": 10.0
		},
		"mill_01": {
			"name": "Мельничный комбинат №1",
			"city": "Валлен",
			"efficiency": 0.88,
			"status": "working",
			"production_per_tick": 25.0
		},
		"elevator_04": {
			"name": "Элеватор №4",
			"city": "Валлен",
			"efficiency": 0.12,
			"status": "idle",
			"production_per_tick": 0.0
		}
	}
	
	# Активные контракты
	contracts = [
		{
			"id": "CTR-412",
			"city": "Валлен",
			"product": "Мука пшеничная в/с",
			"volume_tons": 120,
			"price_per_ton": 2_950,
			"deadline_tick": 4,
			"status": "active",
			"counterparty": "ООО ЗерноТрейд"
		},
		{
			"id": "CTR-387",
			"city": "Нордхейм",
			"product": "Сахар-песок",
			"volume_tons": 45,
			"price_per_ton": 5_420,
			"deadline_tick": 2,
			"status": "delayed",
			"counterparty": "СахарСнаб АГ"
		}
	]
	
	# Алерты
	alerts = [
		{
			"id": "ALT-001",
			"category": "critical",
			"title": "КРИТИЧЕСКИЙ ДЕФИЦИТ: Пекарный завод №2",
			"description": "Запас муки на исходе (хватит на 2 тика). Риск остановки через 04:28.",
			"priority": 1,
			"timestamp": 1732012800
		},
		{
			"id": "ALT-002",
			"category": "critical",
			"title": "Срыв такта поставки: ООО ЗерноТрейд",
			"description": "Контракт №412 задержан на 1 такт. Начислена неустойка +18 200 CR.",
			"priority": 1,
			"timestamp": 1732011000
		},
		{
			"id": "ALT-003",
			"category": "market",
			"title": "Скачок спроса: Сахар-песок (+14%)",
			"description": "Цена в Нордхейме выросла до 5 420 CR/т. Доступно 45 т со Склада №3.",
			"priority": 2,
			"timestamp": 1732009200
		}
	]


## Форматирование денег: 1240500 → "1 240 500 CR"
static func format_money(amount: int) -> String:
	var sign: String = ""
	if amount < 0:
		sign = "-"
		amount = abs(amount)
	var str: String = "%d" % amount
	
	# Вставить пробелы разрядов: с конца по 3 символа
	var result: Array[String] = []
	var i: int = str.length()
	while i > 0:
		var start: int = maxi(0, i - 3)
		result.push_front(str.substr(start, i - start))
		i = start
	
	return sign + " ".join(result) + " CR"


## Форматирование дельты: +12.4% / -3.1%
static func format_delta(percent: float) -> String:
	if percent >= 0:
		return "+%.1f%%" % percent
	else:
		return "%.1f%%" % percent


## Форматирование объёма: 120.5 → "120.5 т"
static func format_tons(tons: float) -> String:
	return "%.1f т" % tons


## Добавление/изменение товара на складе
func set_inventory(item_id: String, quantity: float) -> void:
	inventory[item_id] = quantity
	inventory_changed.emit(item_id, quantity)


## Изменение баланса
func add_balance(amount: int) -> void:
	balance += amount
	balance_changed.emit(balance)
	if amount > 0:
		total_revenue += amount
	else:
		total_expenses += abs(amount)
	net_profit = total_revenue - total_expenses


## Продвижение времени на 1 тик
func advance_tick() -> void:
	tick += 1
	if tick >= 24:
		tick = 0
		day += 1
		if day >= 7:
			day = 0
			week += 1
	tick_changed.emit(week, day, tick)


## Получить строку времени: "Week 12 · Thu"
func get_time_string() -> String:
	var days_ru: Array = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
	return "Week %d · %s" % [week, days_ru[day]]


## Получить обратный отсчёт до следующего тика (HH:MM:SS)
func get_tick_countdown() -> String:
	# Для демо: фиксированное значение
	return "Next tick 02:14:33"
